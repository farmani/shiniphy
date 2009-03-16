package Database
{
	import Search.SearchMenu;
	
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.net.XMLSocket;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	//import mx.controls.Alert;
	
	public class ConnectionHandler extends Sprite
	{

		
		private var DbIPAddr:String = ""; // database server IP address
		private var Login:String = ""; // database login
		private var Password:String = ""; // database password
		private var Command:String = ""; // SQL command to be sent to the database
		private var movieSearch:String = "";
		private var fullInfoId:String = "";
		private var similarId:String = "";
		private var DbName:String = ""; // database name
		private var AppIPAddr:String = ""; // Java application server IP address or DSN name
		private var XMLSck:XMLSocket = new XMLSocket();
		private var Connected:Boolean  = false; 
		private var HConnection:Number = -1; // connection handle
		private var port:Number = -1;
		
		// some filtering boosting
		public var genreBoost:Number = 1.0;
		
		private var outgoingData:String = "<policy-file-request/>\n";
		
		private var searchMenu:SearchMenu = null; 
		private var suggestionData:SuggestionHandler = null;
		
		public var waitingForData:Boolean = false;
		
		public function ConnectionHandler(ipAddr:String, port:int, suggestionData:SuggestionHandler)
		{
			XMLSck.addEventListener( flash.events.Event.CONNECT, onSckConnect);
			XMLSck.addEventListener( flash.events.DataEvent.DATA, onSckReceive);
			
			AppIPAddr = ipAddr;
			this.port = port;
			
			//XMLSck.connect( AppIPAddr, 1008 );
			//Security.loadPolicyFile("xmlsocket://"+ipAddr+":"+1008);
			//Security.loadPolicyFile( "xmlsocket://127.0.0.1/crossdomain.xml");
			
			this.suggestionData = suggestionData;
			
			var egon:Number = 0;
		}
		
		public function filterUpdateSimilar():void{
			
			if( Connected){// && HConnection != -1 ){
				outgoingData = XMLCreateSimilar();
				waitingForData = true;
				
				if( XMLSck.connect( AppIPAddr, port ) == false ){
					  trace( "Not connected." ); 
				}
			}else{
				  trace("Not connected." );
			}
			
		}
		
		// establish connection with server
		public function Connect():void{
			
			Connected = false;
			
			//outgoingData = XMLCreateLogon();
			
			try{		
				if( XMLSck.connect( AppIPAddr, port ) == false ){
					
					throw new Error( "Cannot connect to host: " + AppIPAddr );
				}
			}
			catch( x:Number ){
				trace( x.toString() );
			}
		}
		
		
		// When connection is established send data 
		 public function onSckConnect( success:Boolean ):void{
			 if( success ){
				 Connected = true;
				 XMLSck.send( outgoingData );
				 
			 }else{
				 Connected = false;
				 trace("Error connecting to " + AppIPAddr );
			 }
		 }
		 
		 // On recieve of command
		 public function onSckReceive( retDoc: String ):void{
			  trace( "Receiving: " + retDoc );
			  waitingForData = false;
			  retDoc = retDoc.substr(retDoc.indexOf("<"),retDoc.length - 2 - retDoc.indexOf("<"));
			  var doc:XMLDocument = new XMLDocument( retDoc );
			  ParseReturn( doc );
		  }
		  
		 // Sending different xml commands --------------------------------------------------
		  
		  public function search(searchMenu:SearchMenu, command:String):void{
		  	
		  	this.searchMenu = searchMenu;
		  	movieSearch= command;
		  	
		  	if( Connected){// && HConnection != -1 ){
				outgoingData = XMLCreateSearch();
				waitingForData = true;
				
				if( XMLSck.connect( AppIPAddr, port ) == false ){
					  trace( "Not connected." ); 
				}
			}else{
				  trace("Not connected." );
			}
		  	
		  }
		  
		  public function fullInfo(movieId:Number):void{
		  	
		  	fullInfoId = movieId.toString();
		  	
		  	if( Connected){// && HConnection != -1 ){
				outgoingData = XMLCreateFullInfo();
				waitingForData = true;
				
				if( XMLSck.connect( AppIPAddr, port ) == false ){
					  trace( "Not connected." ); 
				}
			}else{
				  trace("Not connected." );
			}
			
		  }
		  
		  public function findSimilar(movieId:Number):void{
		  	
		  	similarId = movieId.toString();
		  	
		  	if( Connected){// && HConnection != -1 ){
				outgoingData = XMLCreateSimilar();
				waitingForData = true;
				
				if( XMLSck.connect( AppIPAddr, port ) == false ){
					  trace( "Not connected." ); 
				}
			}else{
				  trace("Not connected." );
			}
			
		  }		  
		  
	   // Creation of different xml commands ------------------------------------ 
	   private function XMLCreateSearch():String {
	   	   
	   	   var xmlDoc:XMLDocument = new XMLDocument();
		   var node1:XMLNode = xmlDoc.createElement( "search" );
		   var node2:XMLNode;
		   var node3:XMLNode;
		   
		   xmlDoc.appendChild( node1 ); 
		   node2 = xmlDoc.createElement( "movieSearch" );
		   node1.appendChild( node2 );
		   node3 = xmlDoc.createTextNode( movieSearch );
		   node2.appendChild( node3 );
		
		   
		   var s:String = xmlDoc.toString() + "\n"; // \n required by Java sockets
		   return s;
	   	
	   }

	   private function XMLCreateFullInfo():String {
	   	   
	   	   var xmlDoc:XMLDocument = new XMLDocument();
		   var node1:XMLNode = xmlDoc.createElement( "fullinfo" );
		   var node2:XMLNode;
		   var node3:XMLNode;
		   
		   xmlDoc.appendChild( node1 ); 
		   node2 = xmlDoc.createElement( "movieId" );
		   node1.appendChild( node2 );
		   node3 = xmlDoc.createTextNode( fullInfoId );
		   node2.appendChild( node3 );
		
		   
		   var s:String = xmlDoc.toString() + "\n"; // \n required by Java sockets
		   return s;
	   	
	   }	   


	   private function XMLCreateSimilar():String {
	   	   
	   	   var xmlDoc:XMLDocument = new XMLDocument();
		   var node1:XMLNode = xmlDoc.createElement( "similar" );
		   var node2:XMLNode;
		   var node3:XMLNode;
		   
		   xmlDoc.appendChild( node1 ); 
		   node2 = xmlDoc.createElement( "movieId" );
		   node1.appendChild( node2 );
		   node3 = xmlDoc.createTextNode( similarId );
		   node2.appendChild( node3 );
		   
		   node2 = xmlDoc.createElement( "genreBoost" );
		   node1.appendChild( node2 );
		   node3 = xmlDoc.createTextNode( genreBoost.toString() );
		   node2.appendChild( node3 );
		
		   
		   var s:String = xmlDoc.toString() + "\n"; // \n required by Java sockets
		   return s;
	   	
	   }
		   
		/************************* 
		 * ParseReturn
		 *************************/
		private function ParseReturn( xmsg:XMLDocument ):void{  
			var xnode:XMLNode;
			xnode = xmsg.firstChild;
			
			if(xnode.nodeName == "Search"){
				searchMenu.newSearch(xnode);
				
							
			}else if(xnode.nodeName == "Similar"){
				suggestionData.newSimilarSet(xnode, this);
				
			}
		 }
	}
}



