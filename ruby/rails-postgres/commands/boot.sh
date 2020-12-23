echo "Install dependencies"
cd /app && bundle install --path=vendor/bundle
cd /app && npm install --prefix=vendor/npm

echo "Install appsignal"
cd /integration && rake extension:install

echo "Clean tmp"
rm -rf /app/tmp

echo "Run app"
cd /app && bin/rails server -b 0.0.0.0
