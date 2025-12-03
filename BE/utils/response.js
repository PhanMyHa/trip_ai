// Success response utility
const successResponse = (message, data = null, statusCode = 200) => {
  const response = {
    success: true,
    message
  };

  if (data !== null) {
    response.data = data;
  }

  return response;
};

module.exports = successResponse;
