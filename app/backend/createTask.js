const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');
const dynamodb = new AWS.DynamoDB.DocumentClient();

const TABLE_NAME = process.env.TABLE_NAME;

exports.handler = async (event) => {
  console.log('createTask event:', JSON.stringify(event, null, 2));

  try {
    const body = JSON.parse(event.body || '{}');

    // Input validation
    if (!body.title || typeof body.title !== 'string' || body.title.trim().length === 0) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: JSON.stringify({
          success: false,
          error: 'Validation error',
          message: 'Title is required and must be a non-empty string',
        }),
      };
    }

    const taskId = uuidv4();
    const now = new Date().toISOString();

    const task = {
      taskId,
      title: body.title.trim(),
      description: body.description || '',
      completed: false,
      createdAt: now,
      updatedAt: now,
    };

    // Add TTL if provided (optional, for auto-deletion after X days)
    if (body.ttlDays) {
      const ttlTimestamp = Math.floor(Date.now() / 1000) + (body.ttlDays * 24 * 60 * 60);
      task.ttl = ttlTimestamp;
    }

    const params = {
      TableName: TABLE_NAME,
      Item: task,
    };

    await dynamodb.put(params).promise();

    return {
      statusCode: 201,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'POST,OPTIONS',
      },
      body: JSON.stringify({
        success: true,
        data: task,
      }),
    };
  } catch (error) {
    console.error('Error creating task:', error);

    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        success: false,
        error: 'Failed to create task',
        message: error.message,
      }),
    };
  }
};

