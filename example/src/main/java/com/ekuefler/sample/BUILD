load("//gwt:gwt.bzl", "gwt_application")

gwt_application(
  name = "SampleApp",
  srcs = glob(["*.java"]),
  resources = glob(["*.gwt.xml"]),
  modules = ["com.ekuefler.sample.SampleApp"],
  pubs = glob(["public/*"]),
  compiler_flags = "-strict",
  compiler_jvm_flags = "-Xmx1G",
  dev_flags = "-logLevel DEBUG",
  dev_jvm_flags = "-Xmx1G",
  deps = [
    "//example/src/main/java/com/ekuefler/sample/lib",
  ],
)
