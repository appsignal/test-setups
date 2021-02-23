const { appsignal } = require("./appsignal");

// Initialize express
const express = require('express')
const app = express()
const bodyParser = require('body-parser')

const { expressMiddleware } = require("@appsignal/express");
const { expressErrorHandler } = require("@appsignal/express");

app.use(expressMiddleware(appsignal));
app.set('view engine', 'pug');
app.use(bodyParser.urlencoded({extended: true}));

// Initialize postgres
const Pool = require('pg').Pool
const pool = new Pool({
  user: process.env.POSTGRES_USER,
  host: "postgres",
  database: process.env.POSTGRES_DB,
  password: process.env.POSTGRES_PASSWORD,
  port: 5432,
})

app.get('/', (req, res) => {
  console.log("Request on /")
  pool.query('SELECT * FROM posts ORDER BY id ASC', (error, result) => {
    if (error) {
      throw error
    }
    res.render('index', {posts: result.rows})
  });
})

app.get('/new', (req, res) => {
  console.log("Request on /new")
  res.render('new', {})
})

app.post('/create', (req, res) => {
  console.log("Request on /create")
  const { title, text } = req.body
  pool.query('INSERT INTO posts (title, text) VALUES ($1, $2)', [title, text], (error, results) => {
    if (error) {
      throw error
    }
    res.redirect("/");
  })
})

app.get('/bull', (req, res) => {
  console.log("Request on /bull")
  testFunction();
  res.send("Welcome")
})

app.get('/error', (req, res) => {
  console.log("Request on /error")
  throw new Error("This is an error")
})

app.use(expressErrorHandler(appsignal));

app.listen(3000, () => {
  console.log('Example app listening')
})


function testFunction() {
  var Queue = require('bull');
  // const Redis = require('ioredis')
  // const client = new Redis("/tmp/redis.sock"); // 192.168.1.1:6379

  const client = {redis: {port: 6379, host: process.env.REDIS_URL}}

  const sendRatingMailQueue = new Queue('sendRatingMail', client)

  const data = {
    email: 'foo@bar.com'
  }

  const options = {
    delay: 86400000,
    attempts: 3
  }

  sendRatingMailQueue.add(data, options)

  sendRatingMailQueue.process(async job => {
    await sendRatingMailTo(job.data.email)
  })

}