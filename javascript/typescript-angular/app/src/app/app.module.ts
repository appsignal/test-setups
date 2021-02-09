declare var APPSIGNAL_FRONTEND_API_KEY: string;
declare var APPSIGNAL_REVISION: string;

import { NgModule, ErrorHandler } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import Appsignal from '@appsignal/javascript';
import { createErrorHandlerFactory } from '@appsignal/angular';

import { AppComponent } from './app.component';

const appsignal = new Appsignal({
  key: APPSIGNAL_FRONTEND_API_KEY,
  revision: APPSIGNAL_REVISION
});
appsignal.demo();

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule
  ],
  providers: [
    {
      provide: ErrorHandler,
      useFactory: createErrorHandlerFactory(appsignal)
    }
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
