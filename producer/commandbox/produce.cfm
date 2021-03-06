<cfscript>
setting requesttimeout="999999";
libs = directoryList( getDirectoryFromPath( getCurrentTemplatePath() ) & "/lib", false, "array", "*.jar" );
// create connection factory
factory = createObject( "java", "com.rabbitmq.client.ConnectionFactory", libs ).init();
factory.setUsername( "guest" );
factory.setPassword( "guest" );
// Create a shared connection for this application
connection = factory.newConnection();
// Create new channel for this interaction
channel = connection.createChannel();
// Crete Queue
channel.queueDeclare( 
	"stock.prices", // Name
	javaCast( "boolean", false ), // durable queue, persist restarts
	javaCast( "boolean", false ), // Exclusive queue, restricted to this connection
	javaCast( "boolean", true ), // autodelete, server will delete if not in use
	javaCast( "null", "" ) // other construction arguments
);
// Get a price generator
priceGenerator = new lib.PriceGenerator();
// Produce Price Quotes
while( true ){
	price = priceGenerator.nextPrice();
	systemOutput( "Producing: #price#" & chr(10) );
	// publish
	variables.channel.basicPublish( 
		"", // exchange
		"stock.prices", // routing key
		javaCast( "null", "" ), // properties
		price.getBytes() // message body
	);
	sleep( 200 );
}
</cfscript>
