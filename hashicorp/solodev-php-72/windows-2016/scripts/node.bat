@echo off
echo ---------------------
echo Installing Node
echo ---------------------

choco install nodejs-lts -y

mkdir "C:\inetpub\node_modules_global"
npm config set prefix "C:\inetpub\node_modules_global"
npm install -g --unsafe-perm @fortawesome/fontawesome-free autoprefixer clean-css-cli node-sass npm-run-all postcss postcss-cli gulp gulp-autoprefixer \
		gulp-clean gulp-clean-css gulp-concat gulp-rename gulp-sass gulp-uglify node-sass

mkdir "C:\inetpub\.npm"