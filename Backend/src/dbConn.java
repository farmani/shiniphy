
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
			Class.forName("com.mysql.jdbc.Driver");
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
			String sConn = "jdbc:mysql://" + IPAddr + ":3306/" + Database;
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
	
	public String Search( String movieName ){
		
		String command = "SELECT movieid, title FROM searchstring(ON movie_titles SEARCHFOR('" + movieName + "')) ORDER BY closeness LIMIT 10";
		
		String Return = "";
		String TypeOfReturn = "Search>";
		try{
			//Connect();
			Statement dbStatement = conn.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_READ_ONLY );
			//DatabaseMetaData m = conn.getMetaData();
			//m.getColumns();

			ResultSet dbResults = dbStatement.executeQuery( command );

			while( dbResults.next()){
				Return += "<movie><id>" + dbResults.getString( 1 ) + "</id><name>\"" +dbResults.getString( 2 )+ "\"</name></movie>";
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
	
	public String getFullInfo(String id){
		
		// TODO: create query for getting all relevant information about a movie
		String command = "";
		
		String Return = "";
		String TypeOfReturn = "FullMovie>\n";
		try{
			
			Statement dbStatement = conn.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_READ_ONLY );

			ResultSet dbResults = dbStatement.executeQuery( command );
			
			// TODO:   Add whatever data comes out of query

			while( dbResults.next()){
				Return += "\t<movieid></movieid>\n";
				Return += "\t<title></title>\n";
				Return += "\t<movieid></movieid>\n";
				Return += "\t<movieid></movieid>\n";
				Return += "\t<movieid></movieid>\n";
				Return += "\t<movieid></movieid>\n";
				Return += "\t<movieid></movieid>\n";
				// very simple results processing...
			}
		}catch( Exception x ){
			Return = x.toString();
			Error = x.toString();
			TypeOfReturn = "Error>";
		}
		return "<" + TypeOfReturn + Return + "</" + TypeOfReturn + "\0";
		
	}
	
	public String getAllSimilar(String command){
		
		// TODO create query for getting all similar movies
		return "";
	}
	
	// just downloads the full list of movies
	public ResultSet getFullMovieList(){
		
		try{
			//Connect();
			Statement dbStatement = conn.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE,
				ResultSet.CONCUR_READ_ONLY );
			//DatabaseMetaData m = conn.getMetaData();
			//m.getColumns();

			return dbStatement.executeQuery("select movieid, title from movie_title");

		}catch( Exception x ){
			return null;
		}

	}


	/********************************
	 * Error accessor
	 ********************************/
	public String getError(){
		return Error;
	}
}
