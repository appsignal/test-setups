import Application from '@ember/application';
import Resolver from 'ember-resolver';
import loadInitializers from 'ember-load-initializers';
import config from 'ember-test-setup/config/environment';

export default class App extends Application {
  modulePrefix = config.modulePrefix;
  podModulePrefix = config.podModulePrefix;
  Resolver = Resolver;
}

import Appsignal from '@appsignal/javascript';
import { installErrorHandler } from "@appsignal/ember";
import Ember from 'ember';

const appsignal = new Appsignal({
  key: "<PUSH API KEY HERE>"
})

installErrorHandler(appsignal, Ember)

loadInitializers(App, config.modulePrefix);
