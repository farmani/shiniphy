package Database
{
	import Search.SearchMenu;
	
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.net.XMLSocket;
	import flash.system.Security;
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
		
		private var outgoingData:String = "<policy-file-request/>\n";
		
		private var searchMenu:SearchMenu = null; 
		
		public var waitingForData:Boolean = false;
		
		public function ConnectionHandler(ipAddr:String)
		{
			XMLSck.addEventListener( flash.events.Event.CONNECT, onSckConnect);
			XMLSck.addEventListener( flash.events.DataEvent.DATA, onSckReceive);
			
			AppIPAddr = ipAddr;
			
			//XMLSck.connect( AppIPAddr, 1008 );
			//Security.loadPolicyFile("xmlsocket://"+ipAddr+":"+1008);
			Security.loadPolicyFile( "xmlsocket://127.0.0.1/crossdomain.xml");
			
			
			var egon:Number = 0;
		}
		
		/****************************************** 
		 * Connect
		 * Two step process
		 * Using port 1024
		 ******************************************/
		public function Connect():void{
			
			Connected = false;
			
			//outgoingData = XMLCreateLogon();
			
			try{		
				if( XMLSck.connect( AppIPAddr, 1024 ) == false ){
					
					throw new Error( "Cannot connect to host: " + AppIPAddr );
				}
			}
			catch( x:Number ){
				traceAlert( x.toString() );
			}
		}
		
		
		/**************************************************
		 * Disconnect
		 * The same as sending a
		 * 'disconnect' command
		 * We have to connect every time to send a disconnect
		 * request because there is only one thread servicing
		 * request on the application side.
		 **************************************************/
		public function Disconnect():void{	
			Command = "disconnect";
			try{		
				if( XMLSck.connect( AppIPAddr, 1024 ) == false ){
					Connected = false;
					throw new Error( "Cannot connect to host: " + AppIPAddr );
				}else{
					XMLSck.send( XMLCreateCommand() );
					Connected = false;
					HConnection = -1;
				}
			}
			catch( x:Number ){
				traceAlert( x.toString() );
			}
		}
		
		/************************* 
		 * OnSckConnect
		 * 2nd step of connection
		 *************************/
		 public function onSckConnect( success:Boolean ):void{
			 if( success ){
				 Connected = true;
				 XMLSck.send( outgoingData );
				 
			 }else{
				 Connected = false;
				 traceAlert("Error connecting to " + AppIPAddr );
			 }
		 }
		 
		 /************************
		  * onSckReceive
		  ************************/
		 public function onSckReceive( retDoc: String ):void{
			  traceAlert( "Receiving: " + retDoc );
			  waitingForData = false;
			  retDoc = retDoc.substr(retDoc.indexOf("<"),retDoc.length - 2 - retDoc.indexOf("<"));
			  var doc:XMLDocument = new XMLDocument( retDoc );
			  ParseReturn( doc );
		  }
		  
		 /********************************************************
		  * SendCommand
		  * We have to connect every time to send a command
		  * because there is only one thread servicing
		  * request on the application side. If the Java application
		  * were multithreaded, the if( XMLSck.connect ) ... block 
		  * could be replaced by XMLSck.send( ... )
		  *********************************************************/
		  public function SendCommand(command:String):void{
			
			Command = command;
			  
			if( Connected){// && HConnection != -1 ){
				outgoingData = XMLCreateCommand();
				waitingForData = true;
				
				if( XMLSck.connect( AppIPAddr, 1024 ) == false ){
					  traceAlert( "Not connected." ); 
				}
			}else{
				  traceAlert("Not connected." );
			}
			  
		  }
		  
		  public function search(searchMenu:SearchMenu, command:String):void{
		  	
		  	this.searchMenu = searchMenu;
		  	movieSearch= command;
		  	
		  	if( Connected){// && HConnection != -1 ){
				outgoingData = XMLCreateSearch();
				waitingForData = true;
				
				if( XMLSck.connect( AppIPAddr, 1024 ) == false ){
					  traceAlert( "Not connected." ); 
				}
			}else{
				  traceAlert("Not connected." );
			}
		  	
		  }
		  
		  public function fullInfo(movieId:Number):void{
		  	
		  	fullInfoId = movieId.toString();
		  	
		  	if( Connected){// && HConnection != -1 ){
				outgoingData = XMLCreateFullInfo();
				waitingForData = true;
				
				if( XMLSck.connect( AppIPAddr, 1024 ) == false ){
					  traceAlert( "Not connected." ); 
				}
			}else{
				  traceAlert("Not connected." );
			}
			
		  }
		  
		  public function findSimilar(movieId:Number):void{
		  	
		  	similarId = movieId.toString();
		  	
		  	if( Connected){// && HConnection != -1 ){
				outgoingData = XMLCreateSimilar();
				waitingForData = true;
				
				if( XMLSck.connect( AppIPAddr, 1024 ) == false ){
					  traceAlert( "Not connected." ); 
				}
			}else{
				  traceAlert("Not connected." );
			}
			
		  }		  
		  
	  /*************************
	   * XMLCreateCommand
	   *************************/
	   private function XMLCreateCommand():String {
		   
		   var xmlDoc:XMLDocument = new XMLDocument();
		   var node1:XMLNode = xmlDoc.createElement( "flashCommand" );
		   var node2:XMLNode;
		   var node3:XMLNode;
		   
		   xmlDoc.appendChild( node1 ); 
		   node2 = xmlDoc.createElement( "Command" );
		   node1.appendChild( node2 );
		   node3 = xmlDoc.createTextNode( Command );
		   node2.appendChild( node3 );
		   			   
		   var s:String = xmlDoc.toString() + "\n"; // \n required by Java sockets
		   return s;
	   }
	   
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
		
		   
		   var s:String = xmlDoc.toString() + "\n"; // \n required by Java sockets
		   return s;
	   	
	   }		   
	   
	    private function XMLCreateLogon():String {
		   
		   var xmlDoc:XMLDocument = new XMLDocument();
		   var node1:XMLNode = xmlDoc.createElement( "logon" );
		   var node2:XMLNode;
		   var node3:XMLNode;
		   
		   xmlDoc.appendChild( node1 ); 
		   node2 = xmlDoc.createElement( "message" );
		   node1.appendChild( node2 );
		   node3 = xmlDoc.createTextNode( "Hey what's up?" );
		   node2.appendChild( node3 );
		   			   
		   var s:String = xmlDoc.toString() + "\n"; // \n required by Java sockets
		   return s;
	   }
	   
	   
	   /************************* 
	    * traceAlert
		*************************/
		private function traceAlert( msg:String ):void{
			trace( msg );
		}
		   
		/************************* 
		 * ParseReturn
		 *************************/
		private function ParseReturn( xmsg:XMLDocument ):void{  
			var xnode:XMLNode;
			xnode = xmsg.firstChild;
			
			if( xnode.nodeName == "Connection" ){
				xnode = xnode.firstChild;
				while( xnode != null ){
					if( xnode.nodeName == "HConnection" ){
						xnode = xnode.firstChild;
						HConnection = parseInt(xnode.nodeValue);
						break;
					}
					xnode = xnode.nextSibling;
				}	
			}else if(xnode.nodeName == "Search"){
				searchMenu.newSearch();
				
				xnode = xnode.firstChild;
				while( xnode != null ){
					if( xnode.nodeName == "movie" ){
						xnode = xnode.firstChild;
						var id:int = parseInt(xnode.firstChild.nodeValue);
						xnode = xnode.nextSibling;
						var name:String = xnode.firstChild.nodeValue;
						xnode = xnode.nextSibling;
						var dist:int = parseInt(xnode.firstChild.nodeValue);
						
						if(searchMenu != null){
							
							searchMenu.addResult(id, name, dist);
						}
						
						xnode = xnode.parentNode;

					}
					xnode = xnode.nextSibling;
				}			
			}
		 }
	}
}










