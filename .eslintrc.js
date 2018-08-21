// Specification:
// https://github.com/standard/standard/blob/master/docs/README-en.md
module.exports = {
  root: true,
  extends: 'standard',
  // required to lint *.vue files
  plugins: [
    'html'
  ],
  'rules': {
    // allow paren-less arrow functions
    'arrow-parens': 0,
    // allow debugger during development
    'no-debugger': process.env.NODE_ENV === 'production' ? 2 : 0
  },
  // list of global variables
  'globals': {
    'MediaRecorder': false,
    'FileReader': false,
    'FormData': false,
    'Blob': false,
    'localStorage': false,
    'alert': false,
    'config': true
  }
}
