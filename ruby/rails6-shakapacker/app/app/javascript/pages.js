function hello() {
  console.log("hello")
}

function doSomething() {
  for (let i = 0; i <= 100; i++) {
    doSomethingElse(i)
    if (i == 100) {
      throwError(i)
    }
  }
}

function doSomethingElse(i) {
  "a".repeat(i)
}

function throwError(i) {
  throw new Error(`Hello error ${i}`)
}

(function() {
  hello()
  doSomething()
})()
