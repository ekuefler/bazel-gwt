load("//gwt:gwt.bzl", "gwt_application")

gwt_application(
  name = "SampleApp",
  srcs = glob(["*.java"]),
  resources = glob(["*.gwt.xml"]),
  module = "com.ekuefler.sample.SampleApp",
  pubs = glob(["public/*"]),
  compiler_flags = "-strict",
  deps = [
    "//example/src/main/java/com/ekuefler/sample/lib",
  ],
)
