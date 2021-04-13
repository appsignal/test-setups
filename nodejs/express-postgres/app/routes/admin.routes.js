const admin = require('express').Router();

const userRoutes = require("./user.routes");
admin.use('/user', userRoutes);

admin.get('/', function(req, res){
  res.send('dashboard for admin')
});

admin.get('/settings', function(req, res){
  res.send('listing system settings')
});

module.exports = admin;