const  {app, appsignal}  = require("./express")

// Initialize express
const bodyParser = require('body-parser')

const { expressErrorHandler } = require("@appsignal/express");

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
const adminRoutes = require("./routes/admin.routes");
app.use('/admin', adminRoutes);

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

app.get('/error', (req, res) => {
  console.log("Request on /error")
  throw new Error("This is an error")
})

app.use(expressErrorHandler(appsignal));

app.listen(3000, () => {
  console.log('Example app listening')
})
