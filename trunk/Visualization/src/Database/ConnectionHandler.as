package Database
{
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
		private var DbName:String = ""; // database name
		private var AppIPAddr:String = ""; // Java application server IP address or DSN name
		private var XMLSck:XMLSocket = new XMLSocket();
		private var Connected:Boolean  = false; 
		private var HConnection:Number = -1; // connection handle
		
		private var outgoingData:String = "";
		
		public function ConnectionHandler(ipAddr:String)
		{
			XMLSck.addEventListener( flash.events.Event.CONNECT, onSckConnect);
			XMLSck.addEventListener( flash.events.DataEvent.DATA, onSckReceive);
			
			AppIPAddr = ipAddr;
			
			
		}
		
		public function setUpDatabase(ip:String, username:String, password:String, dbName:String):void{
			
			if(Connected)
				Disconnect();
				
				
			DbIPAddr = ip;
			Login = username;
			Password = password;
			DbName = dbName;
		}
		
		/****************************************** 
		 * Connect
		 * Two step process
		 * Using port 1024
		 ******************************************/
		public function Connect():void{
			
			Connected = false;
			
			outgoingData = XMLCreateLogon();
			
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
				
				if( XMLSck.connect( AppIPAddr, 1024 ) == false ){
					  traceAlert( "Not connected." ); 
				}
			}else{
				  traceAlert("Not connected." );
			}
			  
		  }
		  
		  public function search(command:String):void{
		  	
		  	movieSearch= command;
		  	
		  	if( Connected){// && HConnection != -1 ){
				outgoingData = XMLCreateSearch();
				
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
			   
		   	   node2 = xmlDoc.createElement( "Connection" );
			   node1.appendChild( node2 );
			   node3 = xmlDoc.createTextNode( HConnection.toString());
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
			   
		   	   node2 = xmlDoc.createElement( "Connection" );
			   node1.appendChild( node2 );
			   node3 = xmlDoc.createTextNode( HConnection.toString());
			   node2.appendChild( node3 );
			   
			   var s:String = xmlDoc.toString() + "\n"; // \n required by Java sockets
			   return s;
		   	
		   }
		   
		  /*************************
		   * XMLCreateLogon
		   *************************/
		   private function XMLCreateLogon():String {	   
			   var xmlDoc:XMLDocument = new XMLDocument();
			   var node1:XMLNode = xmlDoc.createElement ( "flashLogon" );
//			   var node2:XMLNode;
//			   var node3:XMLNode;
//			   
			   xmlDoc.appendChild( node1 ); 
//			   node2 = xmlDoc.createElement( "IPAddr" ); //this is the Db IP Addr
//			   node1.appendChild( node2 );
//			   node3 = xmlDoc.createTextNode( DbIPAddr );
//			   node2.appendChild( node3 );
//			   
//			   node2 = xmlDoc.createElement( "Login" );
//			   node1.appendChild( node2 );
//			   node3 = xmlDoc.createTextNode( Login );
//			   node2.appendChild( node3 );
//		
//			   node2 = xmlDoc.createElement( "Password" );
//			   node1.appendChild( node2 );
//			   node3 = xmlDoc.createTextNode( Password );
//			   node2.appendChild( node3 );
//			   
//			   node2 = xmlDoc.createElement( "Database" );
//			   node1.appendChild( node2 );
//			   node3 = xmlDoc.createTextNode( DbName );
//			   node2.appendChild( node3 );	
			   
			    var s:String = xmlDoc.toString() + "\n"; // \n required by Java sockets
			   return s; 
			   // be careful this also appends a \0 which needs to be processed
			   // if multiple reads are performed against the same stream in Java
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
				}
			 }
	}
}