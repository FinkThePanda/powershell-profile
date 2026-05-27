# Postman CLI usage

This project includes a small PowerShell helper for running Postman collections by name.

## Use cases

- Run the local cinema collection: 'collection cinema-local'
- Run the deployed cinema collection: 'collection cinema-dev'
- Run a collection with additional Postman CLI arguments
- Any arguments after the collection name are forwarded to the Postman CLI.

**Examples:**
```powershell
collection <name> [postman-cli-arguments]
collection cinema-local
collection cinema-local --verbose # verbose flag print detailed logs
```

## Available collection names

- cinema-local
- cinema-dev


# Notes
- The first argument must be a known collection name.
- Any extra arguments are passed directly to postman collection run.
- Use postman collection run --help to see supported Postman CLI options.