const { expressErrorHandler } = require("@appsignal/nodejs");
const { createClient } = require("redis");
const bodyParser = require("body-parser");
const express = require("express");

const app = express();
app.set("view engine", "pug");
app.use(bodyParser.urlencoded({extended: true}));

// Initialize Redis
const redisCli = createClient({url: "redis://redis:6379"});
redisCli.connect();

app.get("/", (req, res) => {
  (async () => {
    console.log("Request on /");

    const keys = await redisCli.keys("posts:*");
    let posts = [];

    for (const key of keys) {
      const post = await redisCli.hGetAll(key);
      await posts.push(post);
    }

    await res.render("index", {posts: posts});

  })();
});

app.get("/new", (req, res) => {
  console.log("Request on /new");

  res.render("new", {});
});

app.post("/create", (req, res) => {
  (async () => {
    console.log("Request on /create");
    const { title, text } = req.body;
    const id = await redisCli.incr("postIds");

    await redisCli.sendCommand(
      ["HMSET", `posts:${id}`, "title", title, "text", text]
    );

    res.redirect("/");
  })();
});

app.get("/error", (req, res) => {
  console.log("Request on /error");

  throw new Error("Error in the redis express app");
});

app.get('/slow', async (_req, res) => {
  await new Promise((resolve) => setTimeout(resolve, 3000));
  res.send("Well, that took forever!");
});

app.use(expressErrorHandler());

app.listen(process.env.PORT, () => {
  console.log('Example app listening')
});
