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
import java.util.ArrayList;

public class oSckSrv {

	/*******************************
	 * Members
	 *******************************/
	ServerSocket sckSrv = null;
	int portNumber = 1024;
	Socket sck = null;
	BufferedReader ino = null;
	PrintWriter outo = null;
	ArrayList connections = null;
	String IPAddr = "";
	String Login = "";
	String Password = "";
	String Database = "";
	String Command = "";
	String Output = "";
	int Connection;
	final static int _LOGON = 1;
	final static int _COMMAND = 2;
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
			connections = new ArrayList();

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

				switch( parseReceivedXML( msg )){
					case oSckSrv._LOGON:

					// a login request has been received
					// use the dbConn class to attempt connecting to the database
					// if successful, add the connection information to the
					// connections collection

						dbConn newConnection = new dbConn(IPAddr, Login, Password, Database);
						int tConn = newConnection.getConnection();
						String sConn = "";

						if( tConn != -1 ){
							connections.add( newConnection );
							sConn = sendConnectionInfo( tConn );
							System.out.println( "\tConnection granted: '" + sConn + "'");
							outo.println( sConn );
						}
						else
							System.out.println( "\tConnection cannot be granted: " + newConnection.getError());
						break;

					case oSckSrv._COMMAND:

					// a command has been received; if it is not a 'disconnect'' command,
					// determine the connection that the command is intended for,
					// then execute the command; if it is a 'disconnect'' command,
					// remove the connection from the connections collection

						boolean bFound = false;
						//for( int i = 0; i < connections.size(); i++ ){
						dbConn currentConnection = (dbConn)connections.get( 0 );
					 		if( currentConnection.getConnection() == Connection ){
					 			bFound = true;
								System.out.println( "\tExecuting command for connection " + String.valueOf(Connection));

								if( Command.toLowerCase().compareTo("disconnect") == 0 ){
									System.out.println("\tRemoving connection from pool...");
									connections.remove( 0 );
								}else{
									Output = currentConnection.Execute( Command );
									System.out.println( "\tResult: '" + Output + "'");
									outo.println( Output );
								}
							}
						//}
						if( !bFound )
							System.out.println("\tConnection not found.");
						break;


					case oSckSrv._UNKNOWN:

					// unknown message received

						System.out.println( "\tUnknown command.");
						break;
				}//end switch

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
		oSckSrv s = new oSckSrv();
	}

	/********************************
	 * SendConnectionInfo
	 * Create XML file for connection
	 ********************************/
	public String sendConnectionInfo( int pConnection ){
		return "<Connection><HConnection>" + String.valueOf( pConnection ) + "</HConnection></Connection>\0"; // \0 required by Flash
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

			if( sRoot.compareTo( "flashLogon" ) ==0 ){

				System.out.println( "\tLogon request:");
				NodeList list = oRoot.getChildNodes();
				for( int i = 0; i < list.getLength(); i++){

					Node n = list.item( i );
					String nodeName = n.getNodeName();
					System.out.println( "\t-" + nodeName );
					if( n.getNodeType() == Node.ELEMENT_NODE ){

						Node inner = n.getFirstChild();
						String nodeValue = inner.getNodeValue();
						System.out.println( "\t\t'" + nodeValue + "'" );

						if( nodeName.compareTo( "IPAddr" ) == 0 )
							IPAddr = nodeValue;
						if( nodeName.compareTo( "Login" ) == 0 )
							Login = nodeValue;
						if( nodeName.compareTo( "Password" ) == 0 )
							Password = nodeValue;
						if( nodeName.compareTo( "Database" ) == 0 )
							Database = nodeValue;
					}
				}
				return oSckSrv._LOGON;
			}else{
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

						if( nodeName == "Connection"){
								Connection = Integer.parseInt( n.getFirstChild().getNodeValue());
								nodeValue = String.valueOf( Connection );
						}

						System.out.println( "\t-" + nodeName + ":" + nodeValue );
					}
					return oSckSrv._COMMAND;
				}else{
					System.out.println( "\tUnknown client request");
					return oSckSrv._UNKNOWN;
				}
			}
		}
		catch( Exception e ){
			System.out.println( e.toString());
			return oSckSrv._UNKNOWN ;
		}
	}
}
