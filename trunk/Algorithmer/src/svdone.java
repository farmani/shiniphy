
//import java.lang.Math;
import java.util.*;
import java.io.*;


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
	
	public String getFileName(short movieId, boolean read){
		
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
	
	public static void main(String[] args) {

			svdone svd = new svdone();
			
			try {
				svd.doSvd();
			} catch (FileNotFoundException e) {
				
				e.printStackTrace();
			}


	}

}
