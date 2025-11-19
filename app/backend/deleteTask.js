const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

const TABLE_NAME = process.env.TABLE_NAME;

exports.handler = async (event) => {
  console.log('deleteTask event:', JSON.stringify(event, null, 2));

  try {
    const taskId = event.pathParameters?.id;

    if (!taskId) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({
          success: false,
          error: 'Validation error',
          message: 'Task ID is required',
        }),
      };
    }

    const params = {
      TableName: TABLE_NAME,
      Key: {
        taskId: taskId,
      },
      ReturnValues: 'ALL_OLD',
    };

    const result = await dynamodb.delete(params).promise();

    if (!result.Attributes) {
      return {
        statusCode: 404,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({
          success: false,
          error: 'Task not found',
        }),
      };
    }

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'DELETE,OPTIONS',
      },
      body: JSON.stringify({
        success: true,
        message: 'Task deleted successfully',
        data: result.Attributes,
      }),
    };
  } catch (error) {
    console.error('Error deleting task:', error);

    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        success: false,
        error: 'Failed to delete task',
        message: error.message,
      }),
    };
  }
};

