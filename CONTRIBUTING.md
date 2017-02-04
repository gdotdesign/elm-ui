# Contributing
Thanks for taking the time to contribute! :tada: :confetti_ball: :+1:

### Installation
First, ensure you have [Node.js](https://nodejs.org/en/) and
[Yarn](https://yarnpkg.com) installed on your machine.

To install dependencies run the `yarn` or `yarn install` command, this will
install:
* the `elm`, `elm-github-install` and `elm-spec` packages
* all of the Elm packages that are needed for compiling the project

### Running specs
Specs are added for every component and they are located in the `spec` folder.
You can run all of the specs with the `yarn spec` command or a single spec
with the `yarn spec path/to/spec.elm` command.

Specs can also be run in the browser `yarn start` command, which starts
`elm-reactor` on port `8002`. For example the specs for `Ui.Input` can be
view in the browser at `http://localhost:8002/spec/Ui/InputSpec.elm`.

### Developing
A typical contributor workflow looks like this:

* Create a fork and a feature branch.
* Write some code :hammer:
* Ensure your code is **tested**.
  - If you are changing behavior add specs to cover it
  - If you are creating a new components add specs for it's behavior
* Submit a Pull Request on GitHub.
  - Write a thorough description of your work so that reviewers
    and future developers can understand your code changes.
  - Tests will run automatically for every pull request on
    [travis-ci.org](https://travis-ci.org)
* Your code will be reviewed and merged after approval.
  - You may be asked to make modifications to code style or to fix bugs
    you may have not noticed.
  - Please respond to comments in a timely fashion (even if to tell us
    you need more time).
* Hooray, you contributed! :tophat:
