load("//gwt:gwt.bzl", "gwt_application")

# Use gwt_application to define your app. It will generate two targets: you can
# run `bazel build` on `SampleApp` to create a .war file containing the compiled
# application, or you can run `bazel run` on `SampleApp-dev` to run development
# mode for your application.
gwt_application(
  # Name of the build target. Required.
  name = "SampleApp",

  # Source files and resources to include when running the GWT compiler. A jar
  # is created with these files and included on the classpath during compilation.
  # Make sure to include your .gwt.xml file and any other resources (e.g. css or
  # .ui.xml files) as resources. These are optional here, you don't need to
  # include them of all the files you need exist in other deps.
  srcs = glob(["*.java"]),
  resources = glob(["*.gwt.xml"]),

  # Name of the GWT modules to be compiled, which should correspond to .gwt.xml
  # files. At least one is required.
  modules = ["com.ekuefler.sample.SampleApp"],

  # Files that should be copied directly into the output war, like a static html
  # page that bootstraps the GWT app. Optional.
  pubs = glob(["public/*"]),

  # Optional flags to pass to the GWT compiler and to dev mode. See
  # http://www.gwtproject.org/doc/latest/DevGuideCompilingAndDebugging.html for
  # more details.
  compiler_flags = "-strict",
  compiler_jvm_flags = "-Xmx1G",
  dev_flags = "-logLevel DEBUG",
  dev_jvm_flags = "-Xmx1G",

  # java_libraries that will be included on the classpath when running the GWT
  # compiler. Can contain java classes and resource files.
  deps = [
    "//example/src/main/java/com/ekuefler/sample/lib",
  ],
)
