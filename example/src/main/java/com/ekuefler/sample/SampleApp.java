package com.ekuefler.sample;

import com.ekuefler.sample.lib.Greeter;
import com.google.gwt.core.client.EntryPoint;

/**
 * A simple app that displays "Hello world" in an alert when the page loads.
 */
public class SampleApp implements EntryPoint {
  @Override
  public void onModuleLoad() {
    Greeter.greet();
  }
}
