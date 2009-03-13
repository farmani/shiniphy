
//import java.lang.Math;
import java.sql.Connection;
import java.sql.DriverManager;
//import java.sql.ResultSet;
import java.sql.Statement;
import java.util.*;
import java.io.*;
//import java.net.ServerSocket;
import java.sql.SQLException;

//import searcher.movieInfo;

public class svdone {

	public void doSvd() throws FileNotFoundException{

		// Constants taken from http://www.timelydevelopment.com/demos/NetflixPrize.aspx
		int MAX_RATINGS = 100480508;     // Ratings in entire training set (+1)
		int MAX_USERS = 480190;        // Customers in the entire training set (+1)
		int MAX_MOVIES = 17771;         // Movies in the entire training set (+1)
		int MAX_FEATURES = 64;            // Number of features to use
		int MIN_EPOCHS = 120;           // Minimum number of epochs per feature

		float MIN_IMPROVEMENT = 0.0001f;        // Minimum improvement required to continue current feature
		float INIT = 0.1f;           // Initialization value for features
		float INIT2 = INIT*INIT;
		float LRATE = 0.001f;         // Learning rate parameter
		float K = 0.015f;         // regularizing parameter used to minimize over-fitting



		byte ratings[] = new byte[MAX_RATINGS];
		int users[] = new int[MAX_RATINGS];
		short movies[] = new short[MAX_RATINGS];
		float temp[] = new float[MAX_RATINGS];		

		Map<Integer, Integer> usrIdMapper = new HashMap<Integer, Integer>();

		int i = 0, highest = 0, custid;
		Integer newId;

		Scanner s;
		short movieId = 1;

		// save data in fancy structures.
		while ( movieId < MAX_MOVIES)
		{

			s = new Scanner(new BufferedReader(new FileReader(getFileName(movieId, true))));
			s.useDelimiter(",");
			s.nextLine();

			while (s.hasNext()) {

				custid = s.nextInt();

				// try to find user in current list.
				newId = usrIdMapper.get(custid);

				// if user not found then we add a new relation in map  new id to old id.
				if (newId == null){

					usrIdMapper.put(custid, highest);
					users[i] = highest;
					++highest;

					//ratings[i] = new Rating(highest,inputIterator.getIntAt(1),inputIterator.getIntAt(3));
				}else{
					users[i] = newId;

					//ratings[i] = new Rating(newId,inputIterator.getIntAt(1),inputIterator.getIntAt(3));
				}

				ratings[i] = (byte)s.nextInt();
				movies[i] = movieId;
				temp[i] = 0.0f;

				// skip date
				s.nextLine();

				++i;

			}

			s.close();

			if(movieId % 177 == 0){
				System.out.print(movieId + "\n");
			}

			movieId++;

		}



		int f,e, ratingCount = i, movie, user;
		double err = 0.0f, p = 0.0f, sq = 0.0f, rmse_last = 0.0f, rmse = 2.0f, cf = 0.0f, mf = 0.0f, invRatingCount = 1.0/(double)i,tempVal = 0.0f;

		float movieFeatures[] = new float[MAX_MOVIES];
		float userFeatures[] = new float[MAX_USERS];

		FileOutputStream out; // declare a file output object
		PrintStream pr; // declare a print stream object

		for (f=0; f<MAX_FEATURES; f++)
		{
			Arrays.fill(movieFeatures, INIT);
			Arrays.fill(userFeatures, INIT);

			System.out.print("Starting with feature: " + f + "\n");

			// Keep looping until you have passed a minimum number
			// of epochs or have stopped making significant progress
			for (e=0; (e < MIN_EPOCHS) || (rmse <= rmse_last - MIN_IMPROVEMENT); e++)
			{

				sq = 0;
				rmse_last = rmse;

				for (i=0; i<ratingCount; i++)
				{
					movie = movies[i];
					user = users[i];
					tempVal = (double)temp[i];

					// Cache off old feature values
					cf = userFeatures[user];
					mf = movieFeatures[movie];

					// predict rating and add contribution of current feature
					p = (tempVal > 0.0) ? (tempVal + cf * mf) : (1.0 + cf * mf);

					// clamp
					if (p > 5.0) p = 5.0;
					else if (p < 1.0) p = 1.0;

					err = (double)ratings[i] - p;
					sq += err*err;


					// Cross-train the features
					userFeatures[user] += LRATE * (err * mf - K * cf);
					movieFeatures[movie] += LRATE * (err * cf - K * mf);
				}


				rmse = Math.sqrt(sq*invRatingCount); 

				System.out.print("\tDone with epoch: " + e + " in feature: " + f + ". Currently with (r)mse at " + rmse + "\n");

			}

			// Cache off old predictions
			for (i=0; i<ratingCount; i++)
			{
				p = (temp[i] > 0) ? temp[i] : 1; 

				// Add contribution of current feature
				p += userFeatures[users[i]] * movieFeatures[movies[i]] + (MAX_FEATURES-f-1) * INIT2;

				if (p > 5) p = 5;
				if (p < 1) p = 1;

				temp[i] = (float)p;
			}



			for(i=0; i<MAX_MOVIES;++i){


				try
				{
					// Create a new file output stream
					// connected to "myfile.txt"
					out = new FileOutputStream(getFileName((short)i, false), (f!=0));

					// Connect print stream to the output stream
					pr = new PrintStream( out );

					pr.println (movieFeatures[i]);

					pr.close();
				}
				catch (Exception ecp)
				{
					System.err.println ("Error writing to file");
				}
			}
		}
	}

	public static String getFileName(short movieId, boolean read){

		String Return;

		if(read){
			Return = "D:\\netflix\\download\\training_set\\mv_";
		}else{ 
			Return = "out\\mv_";
		}

		if(movieId >= 10000){
			Return += "00";
		}else if(movieId >= 1000){
			Return += "000";			
		}else if(movieId >= 100){
			Return += "0000";			
		}else if(movieId >= 10){
			Return += "00000";			
		}else{
			Return += "000000";			
		}

		return Return + movieId + ".txt";
	}

	public static void createCluto(){


		Scanner s;
		short movieId = 1;

		FileOutputStream out; // declare a file output object
		
		
		try {
			out = new FileOutputStream("cluto.mat", false);

			PrintStream pr; // declare a print stream object
			// Connect print stream to the output stream
			pr = new PrintStream( out );
			
			pr.println("17770 64");
			try {
			// save data in fancy structures.
				while ( movieId < 17771)
				{
		
					s = new Scanner(new BufferedReader(new FileReader(getFileName(movieId, false))));
					
					//s.useDelimiter(",");
					//s.nextLine();
		
					int i = 0;
					
					//System.out.print(s.nextLine());
		
					while (s.hasNext()) {
		
						if(i == 0)
							pr.print(s.nextLine());
						else
							pr.print(" " + s.nextLine());
						
						++i;
		
					}
					
					pr.println();
		
					s.close();
		
					if(movieId % 177 == 0){
						System.out.print(movieId + "\n");
					}
		
					movieId++;
		
				}
				
				pr.close();
			} catch (FileNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		} catch (FileNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}



	}
	
	public static void genrePredictor(int amountClusters){


		Map<Integer, Vector<Integer> > usrIdMapper = new HashMap<Integer, Vector<Integer> >();

		int genreid, movieid;

		Scanner s;

		try {
			s = new Scanner(new BufferedReader(new FileReader("genresReduced.dat")));


			Vector<Integer> newId;

			// save data in fancy structures.

			while (s.hasNext()) {

				movieid = s.nextInt();
				genreid = s.nextInt();

				// try to find user in current list.
				newId = usrIdMapper.get(movieid);

				// if user not found then we add a new relation in map  new id to old id.
				if (newId == null){

					newId = new Vector<Integer>();
					newId.add(genreid);
					usrIdMapper.put(movieid, newId);

				}else{

					newId.add(genreid);


				}
			}
			//System.out.println("Genre data loaded");
			
			s.close();
			
			//int amountClusters = 10;
			int clusterid = 0;
			
			
			Vector<Vector<Integer> > clusters = new Vector<Vector<Integer> >();
			
			for(int i=0;i<amountClusters;++i){
				
				clusters.add(new Vector<Integer>());
			}
			
			s = new Scanner(new BufferedReader(new FileReader("svd.mat.clustering." + amountClusters)));
			
			int j = 1;
			
			while (s.hasNext()) {

				clusterid = s.nextInt();
				
				clusters.get(clusterid).add(j);
				
				++j;
			}
			
			s.close();
			
			//System.out.println("Clusters created");
			
			Vector<Integer> vec = new Vector<Integer>();
			int amountGenres = 29, moviesWithGenres;
			Integer[] genreCount = new Integer[amountGenres];
			Vector<Integer> miniVec;
			
			
			// Create a new file output stream
			// connected to "myfile.txt"
			FileOutputStream out = new FileOutputStream("genresPredict" + amountClusters +".dat");

			// Connect print stream to the output stream
			PrintStream pr = new PrintStream( out );

			int moviesGenrefied = 0;
			
			for(int i=0;i<amountClusters;++i){
				
				vec = clusters.get(i);
				
				for(j = 0;j<amountGenres;++j){
					
					genreCount[j] = 0;
					
				}
				
				moviesWithGenres = 0;
				
				for(j = 0;j<vec.size();++j){
					miniVec = usrIdMapper.get(vec.get(j));
					
					if(miniVec != null){
						
						for(int k=0;k<miniVec.size();++k){

							genreCount[miniVec.get(k)]++;
						}
						
						moviesWithGenres++;
					}
				}
				
				//Arrays.sort(genreCount);
				
				
				for(j = 0;j<vec.size();++j){
					
					miniVec = usrIdMapper.get(vec.get(j));
					
					if(miniVec == null){
						
						miniVec = new Vector<Integer>();
						
						for(int k = 0;k<amountGenres;++k){
							
							if((float)genreCount[k] / (float)moviesWithGenres > .5){
								
								miniVec.add(k);
								
							}
						}
						
						if(miniVec.size() > 0)
							moviesGenrefied++;
						
						
					}
					
					for(int k = 0;k<miniVec.size();++k){
						
						pr.println(vec.get(j) + " " + miniVec.get(k));
					}
				}
				
				//System.out.println("Doing cluster: " + i);
			}
			
			System.out.println("All done with " + amountClusters + " clusters, additional movies with genres: " + moviesGenrefied);
			pr.close();
			
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public static void createKeywordCluto(){
		
		
		
		Vector<Vector<Integer>> movies = new Vector<Vector<Integer>>();
		
		for(int i=0;i<17770;++i){
			
			movies.add(new Vector<Integer>());
				
		}
		
		Scanner s;
		
		try {
			
			FileOutputStream out = new FileOutputStream("genresPredict300.mat");

			// Connect print stream to the output stream
			PrintStream pr = new PrintStream( out );
			
			FileOutputStream out2 = new FileOutputStream("genresMovieIdMap.dat");

			// Connect print stream to the output stream
			PrintStream pr2 = new PrintStream( out2 );
			
			s = new Scanner(new BufferedReader(new FileReader("genresPredict300.dat")));
			
			pr.println("xxx 28 31536");

			int keyword, movieid;

			while (s.hasNext()) {
				movieid = s.nextInt();
				keyword = s.nextInt();

				movies.get(movieid - 1).add(keyword);
			
			}
			
			Vector<Integer> vec;
			for(int i=0;i<17770;++i){
				
				vec = movies.get(i);
				
				for(int j=0;j<vec.size();++j){
					if(j != 0){
						pr.print(" ");
					}
					pr.print(vec.get(j) + " 1");
				}
				if(vec.size() > 0){
					pr.println();
					pr2.println(i+1);

				}
					
			}
			
			pr.close();
			pr2.close();
			
			
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	class pairType implements Comparable<pairType>{

		int id;
		int var;
		
		public pairType(int id, int var){
			
			this.var = var;
			this.id = id;

		}
		public int compareTo(pairType anotherInfo) throws ClassCastException {
			if(this.id - anotherInfo.id == 0){
				return this.var - anotherInfo.var;
			}
			
			return this.id - anotherInfo.id;
		}

		
	}
	
	public void sortDoubleRow(String inFile, String outFile){
		
		try {
			
			FileOutputStream out = new FileOutputStream(outFile);

			// Connect print stream to the output stream
			PrintStream pr = new PrintStream( out );
			Scanner s = new Scanner(new BufferedReader(new FileReader(inFile)));
			
			Vector<pairType> pairs = new Vector<pairType>();

			while(s.hasNext()){
				pairs.add(new pairType(s.nextInt(), s.nextInt()));

				
				
			}
			
			Collections.sort(pairs);
			
			for(int i=0;i<pairs.size();++i){
				
				pr.println(pairs.get(i).id + " " + pairs.get(i).var);
				
			}
			
			pr.close();
			
		}catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		
	}
	
	public void compareTwo(String inFile, String inFile2, String outFile){
		
		try {
			
			FileOutputStream out = new FileOutputStream(outFile);

			// Connect print stream to the output stream
			PrintStream pr = new PrintStream( out );
			Scanner s = new Scanner(new BufferedReader(new FileReader(inFile)));
			Scanner s2 = new Scanner(new BufferedReader(new FileReader(inFile2)));
			
			Vector<pairType> pairs = new Vector<pairType>();
			Vector<pairType> pairs2 = new Vector<pairType>();

			while(s.hasNext()){
				pairs.add(new pairType(s.nextInt(), s.nextInt()));

			}
			
			Collections.sort(pairs);
			
			while(s2.hasNext()){
				pairs2.add(new pairType(s2.nextInt(), s2.nextInt()));

			}
			
			Collections.sort(pairs2);
			
			Vector<Integer> outo;
			
			for(int i=0;i<pairs.size();++i){
				
				outo = new Vector<Integer>();
				
				for(int j=0;j<pairs2.size();++j){
					
					if(pairs2.get(j).id == pairs.get(i).id){
						outo.add(pairs2.get(j).var);
						//pairs2.remove(j);
					}
				}
				if(outo.size() > 0){
					int tmp = pairs.get(i).id;
					
					pr.print("Original " + tmp + " (");
					while(i < pairs.size() && pairs.get(i).id == tmp){
						
						pr.print(pairs.get(i).var + " ");
						++i;
						
					}
					
					pr.print(")\t\t New (");
					
					for(int k=0;k<outo.size();++k){
						
						pr.print(outo.get(k) + " ");
					}
					pr.println(")");
				}
			}
			
			pr.close();
			
		}catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}	
		
		
	}
	
	public static void loadSvdIntoSql(){
		


		try{
			Class.forName("com.mysql.jdbc.Driver").newInstance();
		}catch( Exception x ){
			
			System.out.print("For name no work\n");
			return;
		}
		
		Connection conn = null;

		try{
			// jdbc:ncluster://host:port/database
			System.out.print("Trying to connect\n");
			conn = DriverManager.getConnection("jdbc:mysql://128.12.147.138:3306/netflix?" + "user=filip&password=filip");
		
		
			System.out.println("Connected!");
	
			try{
				//Connect();
				Statement dbStatement = conn.createStatement();
	
	
				Scanner s;
				short movieId = 1;
	
				// save data in fancy structures.
				while ( movieId < 17771)
				{
	
					s = new Scanner(new BufferedReader(new FileReader(getFileName(movieId, false))));
					s.useDelimiter(",");
					s.nextLine();
					
					int i = 0;
	
					while (s.hasNext()) {
	
						dbStatement.executeQuery( "INSERT INTO svdresults VALUES(" + movieId + ", " + i + ", " + s.nextDouble() + ")");
						++i;
	
					}
	
					s.close();
	
					if(movieId % 177 == 0){
						System.out.print(movieId + "\n");
					}
	
					movieId++;
	
				}
	
	
			}catch( Exception x ){
				System.out.print("query error ab ");
			}
		
		}catch (SQLException ex) {
            System.out.println("SQLException: " + ex.getMessage());
            System.out.println("SQLState: " + ex.getSQLState());
            System.out.println("VendorError: " + ex.getErrorCode());
        }
	}

	public static void main(String[] args) {

		svdone svd = new svdone();
		
		if(false){
			
	
			try {
				svd.doSvd();
			} catch (FileNotFoundException e) {
	
				e.printStackTrace();
			}
		
		}else{
			
			//Integer[] egon = {5, 10, 25, 50, 75, 100, 150, 200, 300, 400, 500};
			
			//for(int i = 0;i < egon.length;++i){
			//genrePredictor(28);
			//}
			//createCluto();
			//loadSvdIntoSql();
			//createKeywordCluto();
			//svd.sortDoubleRow("genresPredict28.dat", "genresPredict28Sorted.dat");
			svd.compareTwo("lostGenres.dat", "lostGenresRegen.dat", "genresLostCompare.dat");
		}


	}

}
