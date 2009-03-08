

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Vector;
import java.util.Collections;


public class searcher {
	
	
	class movieInfo implements Comparable<movieInfo>{
		
		String name;
		int id;
		int dist;
		
		public movieInfo(int id, String name){
			
			this.name = name;
			this.id = id;
			dist = 0;
		}
		public int compareTo(movieInfo anotherInfo) throws ClassCastException {
			return this.dist - anotherInfo.dist;    
		}

		
	}
	
	private boolean loaded = false;
	private movieInfo[] movieData;

	public searcher() {

		// kee kee
		
		
	}
	
	public void load(ResultSet movies){
		
		if(loaded)
			return;
		
		try {
			
			movieData = new movieInfo[17771];
			int i = 0;
			
			while( movies.next()){
				
				movieData[i] = new movieInfo(movies.getInt( 1 ),movies.getString( 2 ));
				++i;
				
			}
			System.out.print("Local movies loaded");
			loaded = true;
			
		} catch (SQLException e) {
			
			System.out.print("Could not load movie titles");
		}
		
		
	}

	
	public String search(String query){
		
		if(!loaded){
			return "<error>movies not loaded</error>";
		}
		
		query = query.toLowerCase();
		
		String Return = "<Search>", name;
		int dist;
		boolean contains;
		
		Vector<movieInfo> results = new Vector<movieInfo>();


		for (movieInfo info : movieData){
			if(info != null){
				name = info.name.toLowerCase();
				dist = LD(query, name);
				contains = name.contains(query);
				
				if(dist < name.length()*.3 || contains){
					
					if(contains)
						dist = (int)Math.min(dist, name.length()/query.length()+ .5 );
					
					info.dist = dist;
					
					results.add(info);
					
				}
			}
				
		}
		
		Collections.sort(results);

		int i = 0;
		
		for (movieInfo info : results){
			
			if(i < 10)
				Return += "<movie><id>" + info.id + "</id><name>" + info.name + "</name><dist>" + info.dist + "</dist></movie>";
			
			++i;
		}
		
		return Return + "</Search>\0";
	}

	//****************************
	// Get minimum of three values
	//****************************
	
	private int Minimum (int a, int b, int c) {
	int mi;
	
	  mi = a;
	  if (b < mi) {
	    mi = b;
	  }
	  if (c < mi) {
	    mi = c;
	  }
	  return mi;
	
	}
	
	//*****************************
	// Compute Levenshtein distance
	//*****************************
	
	public int LD (String s, String t) {
	int d[][]; // matrix
	int n; // length of s
	int m; // length of t
	int i; // iterates through s
	int j; // iterates through t
	char s_i; // ith character of s
	char t_j; // jth character of t
	int cost; // cost
	
	  // Step 1
	
	  n = s.length ();
	  m = t.length ();
	  if (n == 0) {
	    return m;
	  }
	  if (m == 0) {
	    return n;
	  }
	  d = new int[n+1][m+1];
	
	  // Step 2
	
	  for (i = 0; i <= n; i++) {
	    d[i][0] = i;
	  }
	
	  for (j = 0; j <= m; j++) {
	    d[0][j] = j;
	  }
	
	  // Step 3
	
	  for (i = 1; i <= n; i++) {
	
	    s_i = s.charAt (i - 1);
	
	    // Step 4
	
	    for (j = 1; j <= m; j++) {
	
	      t_j = t.charAt (j - 1);
	
	      // Step 5
	
	      if (s_i == t_j) {
	        cost = 0;
	      }
	      else {
	        cost = 1;
	      }
	
	      // Step 6
	
	      d[i][j] = Minimum (d[i-1][j]+1, d[i][j-1]+1, d[i-1][j-1] + cost);
	
	    }
	
	  }
	
	  // Step 7
	
	  return d[n][m];
	
	}
}


