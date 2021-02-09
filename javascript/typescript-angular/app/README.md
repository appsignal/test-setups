# AppSignal Issue 465

A Reproduction of issue 465 in AppSignal Webpack

## Steps for Reproduction

1. `npm install`
2. ensure line 11 is uncommented in `app.component.ts`
3. `npm run build`

Issue:

The error you get is:

`An unhandled exception occurred: ENOENT: no such file or directory, unlink main.js.map`

Note there is no mention why this file does not exist (the actual reason is that the TS compile has failed and it did not produce any .js or .map files).

To fix: Navigate to `node_modules/@appsignal/webpack/dist/cjs/index.js` and on line 189 add a `.catch(() => {})` to the `.unlink()` call and save.

Run `npm run build` again.

You will see the actual typescript error printed out as expected:

```
Error: src/app/app.component.ts:11:3 - error TS2322: Type 'string' is not assignable to type 'boolean'.

11   brokenValue: boolean = 'string';
```
