import java.io.FileOutputStream;
import java.io.PrintStream;
import java.sql.*;

public class PullData {

	public static void main(String argv[]) {
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		try {
			// Class.forName("com.mysql.jdbc.Driver").newInstance();
			Class.forName("com.asterdata.ncluster.Driver").newInstance();

			try {
				String username = "psi";
				String password = "pass19wd";
				String url = "jdbc:ncluster://174.129.187.48:2406/psi";
				FileOutputStream out = new FileOutputStream("test.txt", false); // declare a file output object
				PrintStream pr = new PrintStream( out );
				
				// conn = DriverManager
				// .getConnection("jdbc:mysql://128.12.186.185:3306/db?"
				// + "user=root&password=");
				conn = DriverManager.getConnection(url, username, password);
				try {
					stmt = conn.createStatement();
					rs = stmt
							.executeQuery("SELECT customerid,movies_rated FROM users_stats ORDER by customerid");
					while (rs.next()) {
						pr.println (rs.getInt("customerid")+" "+rs.getInt("movies_rated"));
					}
				} finally {
					if (rs != null) {
						try {
							rs.close();
						} catch (SQLException sqlEx) {
							System.out.println("SQLException: "
									+ sqlEx.getMessage());
						}
						rs = null;
					}
					if (stmt != null) {
						try {
							stmt.close();
						} catch (SQLException sqlEx) {
							System.out.println("SQLException: "
									+ sqlEx.getMessage());
						}

						stmt = null;
					}

					if (conn != null) {
						try {
							conn.close();
						} catch (SQLException sqlEx) {
							// Ignore
						}

						conn = null;
					}
					pr.close();
				}
			} catch (SQLException ex) {
				System.out.println("SQLException: " + ex.getMessage());
				System.out.println("SQLState: " + ex.getSQLState());
				System.out.println("VendorError: " + ex.getErrorCode());
			}
		} catch (Exception ex) {
			System.out.println("Exception: " + ex.getMessage());
		}

//		System.out.println("--------------");
//
//		try {
//			rs = stmt.executeQuery("SELECT movieid,times_rated FROM movies");
//			while (rs.next()) {
//				System.out.println(rs.getInt("movieid")+"\t"+rs.getInt("times_rated"));
//			}
//			rs.close();
//		} catch (Exception ex) {
//			System.out.println("Exception: " + ex.getMessage());
//		}
	}
}