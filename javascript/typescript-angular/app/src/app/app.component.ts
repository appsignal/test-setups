import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent {
  title = 'appsignal-issue465';
  throwError = () => {
    throw new Error('Test error');
  }
  // Intentional TS error
  // Enable this line to test the appsignal/webpack error handling
  // brokenValue: boolean = 'string';
}
