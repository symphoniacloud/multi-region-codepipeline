exports.handler = async (event, context) => {
    const message = `Lambda with ${context.memoryLimitInMB}MB memory invoked at ${new Date()}`;
    console.log("message");
    console.log("Event was: ");
    console.log(JSON.stringify(event))
    return message;
};