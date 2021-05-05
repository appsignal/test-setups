const admin = require('express').Router();

const userRoutes = require("./user.routes");
admin.use('/user', userRoutes);

// Routes For admin
admin.get('/', function(req, res){
  res.send('dashboard for admin')
});

admin.get('/users', function(req, res){
  res.send('listing all users here for admin')
});

admin.get('/users/:id', function(req, res){
  res.send('listing a specific user here for admin')
});

admin.get('/v1/users/text-macros/:id', function(req, res){
  res.send('Test route')
});

admin.get('/settings', function(req, res){
  res.send('listing system settings')
});

module.exports = admin;