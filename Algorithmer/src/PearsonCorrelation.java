import java.util.HashMap;
import java.sql.*;

public class PearsonCorrelation {
//	private static final int NUM_RECORDS = 100480507;
	private static final int NUM_RECORDS = 1004;
	private static final int NUM_USERS = 480189;
	private static final int NUM_MOVIES = 17770;
	private static int nextRelId = 0;
	private static HashMap<Integer, Integer> userMap = new HashMap<Integer, Integer>();

	private static int getRelUserId(int userId) {

		Integer relUserId = userMap.get(userId);
		if (relUserId == null) {
			userMap.put(userId, nextRelId);
			relUserId = nextRelId++;
		}
		return relUserId;

	}

	public static void main(String argv[]) {

		byte[] ratingByUser = new byte[NUM_RECORDS];
		short[] movieByUser = new short[NUM_RECORDS];
		byte[] ratingByMovie = new byte[NUM_RECORDS];
		int[] userByMovie = new int[NUM_RECORDS];
		int[] userIndex = new int[NUM_USERS + 1];
		int[] userNextPlace = new int[NUM_USERS];
		int[] movieIndex = new int[NUM_MOVIES + 1];
		int[] movieNextPlace = new int[NUM_MOVIES];

		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;

		userIndex[NUM_USERS] = NUM_RECORDS;
		int i = 0;
		try {
			//Class.forName("com.mysql.jdbc.Driver").newInstance();
			Class.forName("com.asterdata.ncluster.Driver").newInstance();
			
			try {
				String username = "psi";
				String password = "pass19wd";
				String url = "jdbc:ncluster://174.129.187.48:2406/psi";
				
//				conn = DriverManager
//				.getConnection("jdbc:mysql://128.12.186.185:3306/db?"
//						+ "user=root&password=");
				conn = DriverManager.getConnection(url,
						username, password);
				try {
					stmt = conn.createStatement();
					rs = stmt
					.executeQuery("SELECT customerid,movies_rated FROM users_stats");
					while (rs.next()) {
						int relUserId = getRelUserId(rs.getInt("customerid"));
						userIndex[relUserId] = i;
						userNextPlace[relUserId] = i;
						i += rs.getInt("movies_rated");
						System.out.println("hi handsome");
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
				}
			}
			catch (SQLException ex) {
				System.out.println("SQLException: " + ex.getMessage());
				System.out.println("SQLState: " + ex.getSQLState());
				System.out.println("VendorError: " + ex.getErrorCode());
			}
		} catch (Exception ex) {
			System.out.println("Exception: " + ex.getMessage());
		}

		movieIndex[NUM_MOVIES] = NUM_RECORDS;

		i = 0;
		try {
			rs = stmt.executeQuery("SELECT movieid,times_rated FROM movies");
			while (rs.next()) {
				int relMovieId = rs.getInt("movieid") - 1;
				movieIndex[relMovieId] = i;
				movieNextPlace[relMovieId] = i;
				i += rs.getInt("times_rated");
				System.out.println("yes you");
				}
			rs.close();
		}  catch (Exception ex) {
			System.out.println("Exception: " + ex.getMessage());
		}

		try {
			rs = stmt.executeQuery("SELECT customerid,movieid,rating FROM training_set");

			while (rs.next()) {
				int userId = rs.getInt("customerid");
				int relUserId = getRelUserId(userId);
				short movieId = rs.getShort("movieid");
				int relMovieId = movieId - 1;
				byte rating = rs.getByte("rating");
				movieByUser[userNextPlace[relUserId]] = movieId;
				ratingByUser[userNextPlace[relUserId]] = rating;
				userNextPlace[relUserId]++;
				userByMovie[movieNextPlace[relMovieId]] = userId;
				ratingByMovie[movieNextPlace[relMovieId]] = rating;
				System.out.println("not interested?");
				movieNextPlace[relMovieId]++;
			}
			rs.close();
		} catch (Exception ex) {
			System.out.println("Exception: " + ex.getMessage());
		}

		int[][][] values = new int[NUM_MOVIES][5][5];

		for (i = 0; i < NUM_MOVIES - 1; i++) {
			for (int j = i + 1; j < NUM_MOVIES; j++) {
				for (int k = 0; k < 5; k++) {
					for (int l = 0; l < 5; l++) {
						values[j][k][l] = 0;
					}
				}
			}

			for (int j = movieIndex[i]; j < movieIndex[i + 1]; j++) {
				int relUserId = getRelUserId(userByMovie[j]);
				for (int k = userIndex[relUserId]; k < userIndex[relUserId + 1]; j++) {
					if (movieByUser[k] - 1 > i) {
						values[movieByUser[k] - 1][ratingByUser[k] - 1][ratingByMovie[j] - 1]++;
					}
				}
			}

			for (int j = i + 1; j < NUM_MOVIES; j++) {

				float sum1 = 0;
				float sum2 = 0;
				float sumsq1 = 0;
				float sumsq2 = 0;
				float sumpr = 0;
				float num = 0;

				for (int k = 1; k <= 5; k++) {
					for (int l = 1; k <= 5; l++) {
						int val = values[j][k - 1][l - 1];
						sum1 += l * val;
						sum2 += k * val;
						sumsq1 = l * l * val;
						sumsq2 = k * k * val;
						sumpr = k * l * val;
						num += val;
					}
				}

				float top = sumpr - (sum1 * sum2 / num);
				float bottom = (float) Math.sqrt((sumsq1 - (sum1 * sum1) / num)
						* (sumsq2 - (sum2 * sum2) / num));

				if (bottom != 0) {
					float pearson = (top / bottom) * (num / (num + 10));
					System.out.print((i + 1) + "," + (j + 1) + "," + num + ","
							+ pearson + "\n");
					System.out.print((j + 1) + "," + (i + 1) + "," + num + ","
							+ pearson + "\n");
				}

				else {
					System.out.print((i + 1) + "," + (j + 1) + "," + num + ","
							+ 0 + "\n");
				}
			}
		}
	}
}
