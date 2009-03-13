/****************************************
 * oSckSrv
 * @author Razvan Petrescu
 * Java application server component
 ****************************************/

import java.net.*;
import java.io.*;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.w3c.dom.Node;

public class oSckSrv {

	/*******************************
	 * Members
	 *******************************/
	ServerSocket sckSrv = null;
	int portNumber = 1024;
	Socket sck = null;
	BufferedReader ino = null;
	PrintWriter outo = null;
	dbConn connections = null;
	searcher searchManager = null;
	String IPAddr = "";
	String Login = "";
	String Password = "";
	String Database = "";
	String Command = "";
	String movieSearch = "";
	String fullInfoSearch = "";
	String similarSearch = "";
	String Output = "";

	// if true the search of movies is performed locally, substantially faster but server takes time to start.
	boolean localSearch = true;

	final static int _LOGON = 1;
	final static int _COMMAND = 2;
	final static int _SEARCH = 3;
	final static int _FULLINFO = 4;
	final static int _SIMILAR = 5;
	final static int _UNKNOWN = 0;

	/********************************
	 * Constructor
	 ********************************/
	public oSckSrv()
	{

		try
		{
			sckSrv = new ServerSocket(portNumber);
			System.out.println( "Waiting for connection. Port: " + portNumber );


			IPAddr = "128.12.147.138";
			Login = "filip";
			Password = "filip";
			Database = "netflix";

			connections = new dbConn(IPAddr, Login, Password, Database);


			if( connections.getConnection() != -1 ){

				System.out.println( "\tConnection granted");

			}
			else
				System.out.println( "\tConnection cannot be granted: " + connections.getError());



			searchManager = new searcher();

			if(localSearch)
				searchManager.load(connections.getFullMovieList());

			// Main loop

			while(true)
			{
				sck = sckSrv.accept();
				

				System.out.println( "\n[" + System.currentTimeMillis() +  "] accepted: " + sck.getInetAddress() );

				ino = new BufferedReader( new InputStreamReader( sck.getInputStream()));
				System.out.println("\tIn-stream created.");
				outo = new PrintWriter( sck.getOutputStream(), true );
				System.out.println("\tOut-stream created.");
				
				

				// you should put this on a separate thread
				// to process communication with the client
				// if you don't want to open a socket on the client
				// every time you submit a command

				String msg = ino.readLine();

				// if running on a separate thread,
				// you need the following snippet to skip the end of line
				// marker of the previously received batch

				// if( msg.charAt( 0 ) == '\0' )
				//	 msg = msg.substring( 1 );

				System.out.println( "\tRead: '" + msg + "'" );
				
				if(msg.indexOf("<policy-file-request/>") != -1){
					Output = "<?xml version=\"1.0\"?><cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"1024\" /></cross-domain-policy>";
					outo.println( Output );
					
					continue;
				}

				int recievedMsg = parseReceivedXML( msg );
				
				

				if( connections.getConnection() != -1 ){

					if(recievedMsg == oSckSrv._COMMAND){
						System.out.println( "\tExecuting command for connection " + String.valueOf(connections));


						Output = connections.Execute( Command );
						System.out.println( "\tResult: '" + Output + "'");
						outo.println( Output );

					}else if(recievedMsg == oSckSrv._SEARCH){
						if(!localSearch){
							Output = connections.Search(movieSearch);
						}else{
							Output = searchManager.search(movieSearch);
						}
						System.out.println( "\tResult: '" + Output + "'");
						outo.println( Output );


					}else if(recievedMsg == oSckSrv._FULLINFO){
						
						
						Output = connections.getFullInfo(fullInfoSearch);
						
						
					}else if(recievedMsg == oSckSrv._SIMILAR){
						
						
						Output = connections.getAllSimilar(similarSearch);


					}else if(recievedMsg == oSckSrv._LOGON){

						//
					}else{

						// unknown message received

						System.out.println( "\tUnknown command.");
					}
				}else
					System.out.println("\tConnection not found.");	

				// if running on a separate thread,
				// you would NOT be executing the following two lines:
				// (unless a 'disconnect' command was received or the
				// connection was closed in any other way)

				outo.close() ;
				ino.close();
			}
		}
		catch( Exception e ){
			System.out.println(e.toString());
		}
	}

	/********************************
	 * Main
	 * Entry point into the
	 * application
	 ********************************/
	
	public static void main(String[] args) {
		@SuppressWarnings("unused")
		oSckSrv s = new oSckSrv();

	}


	/********************************
	 * ParseReceivedXML
	 ********************************/
	public int parseReceivedXML( String xmlStr ){
		try{
			FileOutputStream ftemp = new FileOutputStream( "doc.xml");
			ftemp.write( xmlStr.getBytes());
			ftemp.flush();
			ftemp.close();
			DocumentBuilderFactory oFdb = DocumentBuilderFactory.newInstance();
			DocumentBuilder oBldr = oFdb.newDocumentBuilder();
			Document oDoc = oBldr.parse( "doc.xml" );

			Element oRoot = oDoc.getDocumentElement();
			String sRoot = oRoot.getTagName();

			if( sRoot.compareTo( "flashCommand" ) ==0 ){

				System.out.println( "\tCommand request:");
				NodeList list = oRoot.getChildNodes();
				for( int i = 0; i < list.getLength(); i++){
					Node n = list.item( i );
					String nodeName = n.getNodeName();
					String nodeValue = "";

					if( nodeName == "Command" ){
						nodeValue = n.getFirstChild().getNodeValue();
						Command = nodeValue;
					}

					System.out.println( "\t-" + nodeName + ":" + nodeValue );
				}
				return oSckSrv._COMMAND;

			}else if( sRoot.compareTo("search") == 0 ){

				System.out.println( "\tSearch request:");
				NodeList list = oRoot.getChildNodes();
				for( int i = 0; i < list.getLength(); i++){
					Node n = list.item( i );
					String nodeName = n.getNodeName();
					String nodeValue = "";

					if( nodeName == "movieSearch" ){
						nodeValue = n.getFirstChild().getNodeValue();
						movieSearch = nodeValue;
					}

					System.out.println( "\t" + nodeName + ":" + nodeValue );
				}

				return oSckSrv._SEARCH;
				
			}else if( sRoot.compareTo( "fullinfo" ) ==0 ){
			
				System.out.println( "\tFull info request:");
				NodeList list = oRoot.getChildNodes();
				for( int i = 0; i < list.getLength(); i++){
					Node n = list.item( i );
					String nodeName = n.getNodeName();
					String nodeValue = "";

					if( nodeName == "movieId" ){
						nodeValue = n.getFirstChild().getNodeValue();
						fullInfoSearch = nodeValue;
					}

					System.out.println( "\t" + nodeName + ":" + nodeValue );
				}				
				
				return oSckSrv._FULLINFO;
			}else if( sRoot.compareTo( "similar" ) ==0 ){

				
				System.out.println( "\tSimilar movie request:");
				NodeList list = oRoot.getChildNodes();
				for( int i = 0; i < list.getLength(); i++){
					Node n = list.item( i );
					String nodeName = n.getNodeName();
					String nodeValue = "";

					if( nodeName == "movieId" ){
						nodeValue = n.getFirstChild().getNodeValue();
						similarSearch = nodeValue;
					}

					System.out.println( "\t" + nodeName + ":" + nodeValue );
				}	
				
				return oSckSrv._SIMILAR;
			}else if( sRoot.compareTo( "logon" ) ==0 ){

				System.out.println("New client ! ");
				
				
				return oSckSrv._LOGON;

			}else{
				System.out.println( "\tUnknown client request");
				return oSckSrv._UNKNOWN;
			}

		}
		catch( Exception e ){
			System.out.println( e.toString());
			return oSckSrv._UNKNOWN ;
		}
	}
}
