# Atom package for Brunch

This is atom package for [Brunch](http://brunch.io/)

![A screenshot of your package](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif)

## Installation

`apm install brunch-with-atom`

## Features

 - creates new `Brunch` skeleton
 - builds/watches your project using `Brunch`
 - uses different `Brunch` versions

## How to use

 - go to `Packages->Brunch`. Select `new`, `build`, `watch`, `change version` (depends on your needs)
 - run context menu and choose `Brunch new`, `Brunch build`, `Brunch watch` or
 `Brunch stop` (depends on your needs)

 > Brunch commands will work ONLY in project folder

## Commands

 - `Brunch new` creates skeleton from [brunch skeletons list](http://brunch.io/skeletons)
 > Notice: There is present only skeletons which have aliases in [brunch skeletons list](http://brunch.io/skeletons)

 - `Brunch build` builds a `Brunch` project and places the output into `public` directory

 - `Brunch watch` watches `Brunch` app directory for changes and rebuilds the whole project when they happen.

 - `Brunch stop` stops `build` or `watch` process.

 - `Brunch change version` changes version of `Brunch` due to selected one.
 > Notice: After selecting another version you have to wait until `npm install` will be finished for selected version.

 For more `Brunch` doc look [here](https://github.com/brunch/brunch/blob/master/docs/commands.md)


 If you don't have internet connection it will work fine, but without generating skeletons.
