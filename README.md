# Kindbody Ruby on Rails and React Code Samples

This repository contains discrete code samples for Ruby on Rails and React, suitable for demonstrating my coding skills for Kindbody.  
  
  
  
  


## Ruby on Rails Code Samples

The Ruby on Rails code samples in this repository demonstrate my proficiency in building web applications using the Ruby on Rails framework. The code samples include:



### accounts_controller.rb

The controller includes several modules such as Searchable, Filterable, and PromoCodable which add functionality to the controller.

The index action responds with a view displaying a table of accounts, while the datatable action responds with the same data in JSON format, which is used to populate the table in the frontend. The new action displays a form to create a new account, while the create action receives the form submission, creates a new account, and sends an email invitation to the owner of the account. The update action updates the attributes of an existing account, and the cancel and destroy actions are used to cancel and delete accounts, respectively.

There are several private helper methods, such as set_accounts_data, which sets instance variables that are used in several actions, set_accounts, which retrieves the accounts from the database, and filters and paginates them based on the search and filter parameters provided by the user, and new_account_params, which defines the list of permitted parameters for the create action.


### answer.rb:

A model file that defines the schema for a answer table in the database and has some basic validations, helper methods and relationships.

### text_response_import.rb:
A Ruby module that defines a class called HolidayPay::TextResponseImport which is responsible for processing and importing data from a text file. The module makes use of several other modules (Helpers::Attributes, Helpers::Callable, Helpers::AdminAuthorization, and Helpers::OperationErrorCatcher) to extend its functionality.

The HolidayPay::TextResponseImport class has two attributes: actor and file, and it defines a constant HEADERS that maps two symbols (worker_id and timestamp) to their respective string header names.

The call method is the main entry point for the class, which parses the data in the text file, validates that all required headers are present, and then calls two private methods make_weekly_requests and make_historic_requests to import data into the HolidayPay::WeeklyRequest and HolidayPay::HistoricRequest tables respectively. Both methods return the number of rows imported and a list of warnings.

The make_weekly_requests method processes the rows in the text file to create new HolidayPay::WeeklyRequest records in the database. It first validates all rows using the validate_rows method, which returns a list of warnings and a list of valid rows. It then inserts valid rows into the database using the HolidayPay::WeeklyRequest.insert_all method, which allows inserting multiple records in one SQL statement.

The make_historic_requests method is similar to make_weekly_requests, but it creates new HolidayPay::HistoricRequest records instead. In addition to validating rows and inserting records, it also retrieves some additional data for each record from the Worker and GetHistoricAccrualStatement classes.

The module also defines several private methods that help with validating data, creating new PayoutPeriod objects, and retrieving existing records from the database.

Finally, the module uses the prepend method to include several helper modules (Helpers::Attributes, Helpers::Callable, Helpers::AdminAuthorization, and Helpers::OperationErrorCatcher) in the class. This is similar to include, but it adds the module to the beginning of the ancestor chain, allowing it to override methods in the class.

### imorts_api_spec:

This is a Ruby code that defines a test suite for the API::V2::Admin::Imports::ImportsAPI endpoint of a Rails application which uses the module defined in text_response_import.rb. The test suite has multiple test cases, each testing a specific scenario of the endpoint's behavior.

The first test case tests a valid import scenario and expects the weekly text responses to be imported correctly. The next test cases test scenarios where the imported file has invalid headers, unknown workers, invalid timestamps, and workers with no historic holiday pay. The last test case tests a scenario where the pay requests already exist, and the test expects to see warning messages.

The test suite uses the RSpec testing framework and fixtures to simulate file uploads and database records.

### filterable.rb:
This is a Ruby module called "Filterable" that defines methods for filtering data by choice and range. The module extends ActiveSupport::Concern and includes private methods for filtering by account status and constructing Elasticsearch clauses. The filter_params method is used to serialize data and store it in an instance variable. The serialize_data method extracts filter values from the request parameters and organizes them into a hash. The filter_by_choice method takes a field name and returns an Elasticsearch clause based on the specified choice and field value. The filter_by_range method takes a field name and returns an Elasticsearch clause based on the specified range of field values.


### searchable.rb:
This is a module in Ruby that adds search functionality to several models using the Searchkick gem. Here's a brief overview of the methods:

elasticsearch_lookup is the main method that handles searching for a given term across several models.
search_for is a helper method that uses the Searchkick.search method to actually perform the search.
The remaining methods are private and define the specific search scopes for each model.
The models that can be searched are Curriculum, Course, and Step, and depending on the user's plan and permissions, Question and Answer models may also be included in the search. Similarly, if the user has the necessary permissions, Survey::Survey and Survey::Question models may be included as well.

Each model has its own private method that defines the search scope, including any filters and select columns. The columns that are selected vary depending on the model, but all include the unpublished flag, which indicates if the model is not yet published.

Overall, this module provides a flexible and extensible way to perform search across several models in a Rails application.


## React Code Samples
The React code samples in this repository demonstrate my proficiency in building dynamic user interfaces using the React library. The code samples include:

A Pages folder that contains and index page for displaying user transactions, it doesn't have any logic and just render the component coming from components directory.

A Components folder that includes all the logic for different components related to transactions page, it also includes storybook and test cases for these components and a constant file for holding constant values used in the code. 


## Contact
If you have any questions about these code samples or would like to discuss my qualifications further, please feel free to contact me at umersajjad.dev@gmail.com.
