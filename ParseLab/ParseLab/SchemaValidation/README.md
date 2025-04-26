# JSON Schema Validation

## About
ParseLab now includes JSON Schema validation as a feature to validate JSON documents against JSON Schema specifications. This helps ensure that your JSON data conforms to a specific structure and data types.

## Features
- Validate JSON documents against JSON Schema
- Use sample JSON Schema for testing
- Upload custom JSON Schema files
- View detailed validation errors with path information
- Test with sample valid and invalid JSON files

## How to Use

### Basic Validation
1. Open a JSON file in ParseLab
2. Click the "Validate Schema" button in the toolbar
3. By default, the sample schema will be loaded
4. Click "Validate" to check if your JSON conforms to the schema

### Using Custom Schema
1. In the Schema Validation screen, select "Upload Schema"
2. Click the "Upload Schema" button
3. Choose a JSON Schema file from your device
4. Click "Validate" to check your JSON against the custom schema

### Sample Tests
1. Click "Load Sample Tests" in the Schema Validation screen
2. In the Sample Schema Test screen, you can switch between valid and invalid sample files
3. View the JSON document and the schema it will be validated against
4. Click "Validate" to see the validation results

## Error Details
When validation fails, you'll see detailed error messages that include:
- The JSON path where the error occurred
- The specific validation rule that failed
- Additional context about the error

## Sample Schema
The included sample schema validates a person object with:
- Required name, age, email, and address fields
- String length constraints on the name field
- Age range constraints
- Email format validation using regex pattern
- Nested address object with required fields
- Optional phone numbers array with type validation
- Prevention of additional undeclared properties

## Future Enhancements
Future versions may include:
- Schema editor for creating and modifying schemas
- Support for additional JSON Schema draft versions
- Ability to save and manage multiple schemas
- Auto-generation of sample JSON from a schema

## Implementation Details
The JSON Schema validation is implemented in the `JSONSchemaValidator` class, which provides a simple API for validating JSON data against a schema. The validation results are returned as a Swift `Result` type, making it easy to handle both success and failure cases.
