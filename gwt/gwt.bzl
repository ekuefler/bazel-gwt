def _gwt_war_impl(ctx):
  output_war = ctx.outputs.output_war
  output_dir = output_war.path + ".gwt_output"
  extra_dir = output_war.path + ".extra"

  # Find all transitive dependencies
  all_deps = get_dep_jars(ctx)

  # Run the GWT compiler
  cmd = "external/local_jdk/bin/java %s -cp %s com.google.gwt.dev.Compiler %s -war %s -deploy %s -extra %s %s\n" % (
    " ".join(ctx.attr.jvm_flags),
    ":".join([dep.path for dep in all_deps]),
    " ".join(ctx.attr.modules),
    output_dir + "/" + ctx.attr.output_root,
    output_dir + "/" + "WEB-INF/deploy",
    extra_dir,
    " ".join(ctx.attr.compiler_flags),
  )

  # Copy pubs into the output war
  if len(ctx.files.pubs) > 0:
    cmd += "cp -r %s %s\n" % (
      " ".join([pub.path for pub in ctx.files.pubs]),
      output_dir,
    )

  # Don't include the unit cache in the output
  cmd += "rm -rf %s/gwt-unitCache\n" % output_dir

  # Discover all of the generated files and write their paths to a file. Run the
  # paths through sed to trim out everything before the package root so that the
  # paths match how they should look in the war file.
  cmd += "find %s -type f | sed 's:^%s/::' > file_list\n" % (
      output_dir,
      output_dir,
  )

  # Create a war file using the discovered paths
  cmd += "root=`pwd`\n"
  cmd += "cd %s; $root/%s Cc ../%s @$root/file_list\n" % (
      output_dir,
      ctx.executable._zip.path,
      output_war.basename,
  )
  cmd += "cd $root\n"

  # Execute the command
  ctx.action(
    inputs = ctx.files.pubs + list(all_deps) + ctx.files._jdk + ctx.files._zip,
    outputs = [output_war],
    mnemonic = "GwtCompile",
    command = "set -e;" + cmd,
  )

_gwt_war = rule(
  implementation = _gwt_war_impl,
  attrs = {
    "deps": attr.label_list(allow_files=FileType([".jar"])),
    "pubs": attr.label_list(allow_files=True),
    "modules": attr.string_list(mandatory=True),
    "output_root": attr.string(default="."),
    "compiler_flags": attr.string_list(),
    "jvm_flags": attr.string_list(),
    "_implicitdeps": attr.label_list(default=[
      Label("//external:asm"),
      Label("//external:javax-validation"),
      Label("//external:javax-validation-src"),
      Label("//external:gwt-dev"),
      Label("//external:gwt-user"),
    ]),
    "_jdk": attr.label(
      default=Label("//tools/defaults:jdk")),
    "_zip": attr.label(
      default=Label("@bazel_tools//tools/zip:zipper"),
      executable=True,
      single_file=True),
  },
  outputs = {
    "output_war": "%{name}.war",
  },
)

def _gwt_dev_impl(ctx):
  # Find all transitive dependencies that need to go on the classpath
  all_deps = get_dep_jars(ctx)
  dep_paths = [dep.short_path for dep in all_deps]

  # Copy pubs to the war directory
  cmd = "rm -rf war\nmkdir war\ncp -LR %s war\n" % (
    " ".join([pub.path for pub in ctx.files.pubs]),
  )

  # Set up a working directory for dev mode
  cmd += "mkdir -p dev-workdir\n"

  # Determine the root directory of the package hierarchy. This needs to be on
  # the classpath for GWT to see changes to source files.
  cmd += "javaRoot=$(pwd | sed -e 's:\(.*\)%s.*:\\1:')../../../%s\n" % (ctx.attr.package_name, ctx.attr.java_root)

  # Run dev mode
  cmd += "java %s -cp $javaRoot:%s com.google.gwt.dev.DevMode -war %s -workDir ./dev-workdir %s %s\n" % (
    " ".join(ctx.attr.jvm_flags),
    ":".join(dep_paths),
    "war/" + ctx.attr.output_root,
    " ".join(ctx.attr.dev_flags),
    " ".join(ctx.attr.modules),
  )

  # Return the script and all dependencies needed to run it
  ctx.file_action(
    output = ctx.outputs.executable,
    content = cmd,
  )
  return struct(
    executable = ctx.outputs.executable,
    runfiles = ctx.runfiles(files = list(all_deps) + ctx.files.pubs),
  )

_gwt_dev = rule(
  implementation = _gwt_dev_impl,
  attrs = {
    "package_name": attr.string(mandatory=True),
    "java_root": attr.string(mandatory=True),
    "deps": attr.label_list(mandatory=True, allow_files=FileType([".jar"])),
    "modules": attr.string_list(mandatory=True),
    "pubs": attr.label_list(allow_files=True),
    "output_root": attr.string(default="."),
    "dev_flags": attr.string_list(),
    "jvm_flags": attr.string_list(),
    "_implicitdeps": attr.label_list(default=[
      Label("//external:asm"),
      Label("//external:javax-validation"),
      Label("//external:javax-validation-src"),
      Label("//external:gwt-dev"),
      Label("//external:gwt-user"),
    ]),
  },
  executable = True,
)

def get_dep_jars(ctx):
  all_deps = set(ctx.files._implicitdeps + ctx.files.deps)
  for this_dep in ctx.attr._implicitdeps + ctx.attr.deps:
    if hasattr(this_dep, 'java'):
      all_deps += this_dep.java.transitive_runtime_deps
      all_deps += this_dep.java.transitive_source_jars
  return all_deps

def gwt_application(
    name,
    srcs=[],
    resources=[],
    modules=[],
    deps=[],
    visibility=[],
    pubs=[],
    output_root=".",
    java_root="src/main/java",
    compiler_flags=[],
    compiler_jvm_flags=[],
    dev_flags=[],
    dev_jvm_flags=[]):
  # Create a java_library to hold any srcs or resources passed in directly
  native.java_library(
    name = name + "-lib",
    srcs = srcs,
    deps = deps + [
      "//external:gwt-user",
    ],
    resources = resources,
  )
  _gwt_war(
    name = name,
    output_root = output_root,
    deps = deps + [name + "-lib"],
    modules = modules,
    visibility = visibility,
    pubs = pubs,
    compiler_flags = compiler_flags,
    jvm_flags = compiler_jvm_flags,
  )
  _gwt_dev(
    name = name + "-dev",
    java_root = java_root,
    output_root = output_root,
    package_name = PACKAGE_NAME,
    deps = deps + [name + "-lib"],
    modules = modules,
    visibility = visibility,
    pubs = pubs,
    dev_flags = dev_flags,
    jvm_flags = dev_jvm_flags,
  )

def gwt_repositories():
  native.maven_jar(
    name = "asm_artifact",
    artifact = "org.ow2.asm:asm:5.0.3",
  )
  native.maven_jar(
    name = "gwt_dev_artifact",
    artifact = "com.google.gwt:gwt-dev:2.8.0-beta1",
  )
  native.maven_jar(
    name = "gwt_user_artifact",
    artifact = "com.google.gwt:gwt-user:2.8.0-beta1",
  )
  native.maven_jar(
    name = "javax_validation_artifact",
    artifact = "javax.validation:validation-api:1.0.0.GA",
  )
  native.http_jar(
    name = "javax_validation_sources_artifact",
    url = "http://repo1.maven.org/maven2/javax/validation/validation-api/1.0.0.GA/validation-api-1.0.0.GA-sources.jar",
 )

  native.bind(
    name = "asm",
    actual = "@asm_artifact//jar",
  )
  native.bind(
    name = "javax-validation",
    actual = "@javax_validation_artifact//jar",
  )
  native.bind(
    name = "javax-validation-src",
    actual = "@javax_validation_sources_artifact//jar",
  )
  native.bind(
    name = "gwt-dev",
    actual = "@gwt_dev_artifact//jar",
  )
  native.bind(
    name = "gwt-user",
    actual = "@gwt_user_artifact//jar",
  )
