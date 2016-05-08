load("//gwt:gwt.bzl", "gwt_application")

java_library(
  name = "sample",
  srcs = glob(["*.java"]),
  resources = glob(["*.gwt.xml"]),
  deps = [
    "//external:gwt-user",
  ],
)

gwt_application(
  name = "SampleApp",
  module = "com.ekuefler.sample.SampleApp",
  pubs = glob(["public/*"]),
  compiler_flags = "-strict",
  deps = [
    ":sample",
  ],
)
