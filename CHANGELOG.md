# Changelog

## [1.2.0](https://github.com/folke/drop.nvim/compare/v1.1.0...v1.2.0) (2024-07-06)


### Features

* **themes:** new themes and automatic theme switcher! ([#18](https://github.com/folke/drop.nvim/issues/18)) ([1bb5ce2](https://github.com/folke/drop.nvim/commit/1bb5ce2e3bef6e858a67fe72a4710b750d04ba45))

## [1.1.0](https://github.com/folke/drop.nvim/compare/v1.0.0...v1.1.0) (2023-03-12)


### Features

* add summer and spring themes ([#11](https://github.com/folke/drop.nvim/issues/11)) ([fa70cb7](https://github.com/folke/drop.nvim/commit/fa70cb79a8c32a531567b59d88a6018c4a04fe6b))

## 1.0.0 (2023-01-04)


### Features

* added stars ([049ac75](https://github.com/folke/drop.nvim/commit/049ac75cfdea62b8984a98a4788f7ef55ba04515))
* added winblend option ([734678c](https://github.com/folke/drop.nvim/commit/734678c5e4f3c1e5499d82be5cce56f5bc417fd0))
* added xmas theme ([30e09ff](https://github.com/folke/drop.nvim/commit/30e09ff92ea284e0ab17dbec38ff16dbf5d9122a))
* initial commit ([5349b9f](https://github.com/folke/drop.nvim/commit/5349b9f5e9e3b753300845679637ed847f439263))
* properly made drop background transparent without losing color of the drops ([79da940](https://github.com/folke/drop.nvim/commit/79da94038b56a7b0232b387067d1fba2c30f9ff7))


### Bug Fixes

* hide drops with vim.schedule. Fixes [#6](https://github.com/folke/drop.nvim/issues/6) ([d9bd4ff](https://github.com/folke/drop.nvim/commit/d9bd4ff8c9eaca89334fe9011ea736f35603b892))
* potential stuck snowflake top left ([15db372](https://github.com/folke/drop.nvim/commit/15db372711c5ba936556959d924d95c2efd0da20))
* re-init drop when failed to set extmark ([f0184df](https://github.com/folke/drop.nvim/commit/f0184df8ef6bea132140512a31cfdbce74d78d42))
* redraw after updating drops so that it still renders during blocking events ([6f2c550](https://github.com/folke/drop.nvim/commit/6f2c550cb6c564a5012c185400f9c4d4bd64b783))
* render speed ([290ed07](https://github.com/folke/drop.nvim/commit/290ed07cfb497ae47315168725192f5623ce4f98))
* resize drop area on VimResized ([dce331a](https://github.com/folke/drop.nvim/commit/dce331ab6b6755c1278c605004481b16d580a4a5))
* schedule wrap screensaver. Fixes [#4](https://github.com/folke/drop.nvim/issues/4) ([3511533](https://github.com/folke/drop.nvim/commit/3511533fcef37e2ef1b49538157c517133d24de3))
* set zindex to 10 to make sure other floats are visible. Fixes [#3](https://github.com/folke/drop.nvim/issues/3) ([7dec467](https://github.com/folke/drop.nvim/commit/7dec4677a404e0383341a7efcf41d8e58d64d250))
* snowflakes no longer get stuck on the left side of the editor ([69dd33a](https://github.com/folke/drop.nvim/commit/69dd33a8e0de17d92bb400a6264f7883833cbca8))


### Performance Improvements

* better performance and fix memory leak ([96555d3](https://github.com/folke/drop.nvim/commit/96555d32bf812d0f57627b8d9f511c03f2a39594))
* use one window and extmarks to render the drops ([8cbd41c](https://github.com/folke/drop.nvim/commit/8cbd41c6ed3163aca6dd90cd2ee8720202c51412))
