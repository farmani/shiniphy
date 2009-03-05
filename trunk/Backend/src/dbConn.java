
/************************************
 * dbConn
 * @author Razvan Petrescu
 * Java database connection manager
 * Works with SQL Server via JDBC
 ************************************/


import java.sql.Connection;
//import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;


public class dbConn {
	private static int MaxConnection = 0;
	private int HConnection;
	private String IPAddr;
	private String Login;
	private String Password;
	private String Database;
	private String Error = "";
	private Connection conn = null;


	/********************************
	 * Constructor
	 ********************************/
	public dbConn( String pIPAddr, String pLogin, String pPassword, String pDatabase ){

		IPAddr = pIPAddr;
		Login = pLogin;
		Password = pPassword;
		Database = pDatabase;

		try{
			Class.forName("com.asterdata.ncluster.Driver");
		}catch( Exception x ){
			Error = x.toString();
			HConnection = -1;
			return;
		}

		if( Success()){
			dbConn.MaxConnection ++;
			HConnection = dbConn.MaxConnection;
		}
		else{
			HConnection = -1;
			System.out.println("\t* Connect failed: " + Error);
		}
	}

	/********************************
	 * Connection handle accessor
	 ********************************/
	public int getConnection(){
		return HConnection;
	}


	/********************************
	 * Validate connection info
	 ********************************/
	public boolean Success(){
		if( Connect()){
			//Disconnect();
			return true;
		}else{
			Error += " Connect unsuccessful.";
			return false;
		}
	}


	/********************************
	 * Connect to database
	 ********************************/
	public boolean Connect(){
		try{
			// jdbc:ncluster://host:port/database
			String sConn = "jdbc:ncluster://" + IPAddr + ":2406/" + Database;
			System.out.println( "\t* Attempting to connect to: " + sConn + "(" + Login + ", " + Password + ")");
			conn = DriverManager.getConnection( sConn, Login, Password );
		}catch( Exception x ){
			Error = x.toString();
			return false;
		}

		Error = "";
		return true;
	}


	/********************************
	 * Disconnect from database
	 ********************************/
	public void Disconnect(){
		try{
			conn.close();
		}catch( Exception x){
			System.out.println("\t* Error closing connection: " + x.toString());
		}
	}


	/***********************************
	 * Execute command against database
	 ***********************************/
	public String Execute( String command ){
		String Return = "";
		String TypeOfReturn = "Return>";
		try{
			//Connect();
			Statement dbStatement = conn.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_READ_ONLY );
			//DatabaseMetaData m = conn.getMetaData();
			//m.getColumns();

			ResultSet dbResults = dbStatement.executeQuery( command );

			while( dbResults.next()){
				Return += dbResults.getString( 1 );	 
				// very simple results processing...
			}
		}catch( Exception x ){
			Return = x.toString();
			Error = x.toString();
			TypeOfReturn = "Error>";
		}
		return "<" + TypeOfReturn + Return + "</" + TypeOfReturn + "\0";
			// '\0' required by Flash
	}
	
	public String Search( String command ){
		String Return = "";
		String TypeOfReturn = "Search>\n";
		try{
			//Connect();
			Statement dbStatement = conn.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_READ_ONLY );
			//DatabaseMetaData m = conn.getMetaData();
			//m.getColumns();

			ResultSet dbResults = dbStatement.executeQuery( command );

			while( dbResults.next()){
				Return += "\t<movie>\n\t\t<id>" + dbResults.getString( 1 ) + "</id>\n\t\t<name>\"" +dbResults.getString( 2 )+ "\"</name>\n\t</movie>\n";
				// very simple results processing...
			}
		}catch( Exception x ){
			Return = x.toString();
			Error = x.toString();
			TypeOfReturn = "Error>";
		}
		return "<" + TypeOfReturn + Return + "</" + TypeOfReturn + "\0";
			// '\0' required by Flash
	}


	/********************************
	 * Error accessor
	 ********************************/
	public String getError(){
		return Error;
	}
}
