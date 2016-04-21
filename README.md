# Atom package for Brunch

This is atom package for [Brunch](http://brunch.io/)

![A screenshot of your package](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif)

## Installation

`apm install brunch-with-atom`

## Features

 - creates new `brunch` skeleton
 - builds/watches your project using `brunch`

## How to use

 - go to `Packages->Brunch`. Select `new`, `build`, `watch` (depends on your needs)
 - run context menu and choose `Brunch new`, `Brunch build`, `Brunch watch` or
 `Brunch stop` (depends on your needs)

 > Brunch commands will work ONLY in project folder

## Commands

 `Brunch new` creates skeleton from [brunch skeletons list](http://brunch.io/skeletons)
 > Notice: There present only skeletons which have aliases in [brunch skeletons list](http://brunch.io/skeletons)

 `Brunch build` builds a brunch project and places the output into `public` directory

 `Brunch watch` watches brunch app directory for changes and rebuilds the whole project when they happen.

 `Brunch stop` stops `build` or `watch` process.

 For more `Brunch` doc look [here](https://github.com/brunch/brunch/blob/master/docs/commands.md)


 If you don't have internet connection it will work fine, but without generating skeletons.
