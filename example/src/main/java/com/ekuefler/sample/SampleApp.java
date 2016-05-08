package com.ekuefler.sample;

import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.user.client.Window;

/**
 * A simple app that displays "Hello world" in an alert when the page loads.
 */
public class SampleApp implements EntryPoint {
  @Override
  public void onModuleLoad() {
    Window.alert("Hello world!");
  }
}
