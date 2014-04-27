import org.apache.commons.math3.stat.regression.OLSMultipleLinearRegression;
import org.apache.commons.math3.linear.Array2DRowRealMatrix;
import org.apache.commons.math3.linear.QRDecomposition;
import java.io.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class InfluenceModel {
	//PARAMETERS
	static final int N = 200,	//Number of nodes. This must match the settings of the previous phases
			S = 20,	//Size of the subset
			K = 20;	//Number of random subsets tested
	
	public static void main(String[] args) {
		String filename = "Graph_" + N;
		String[] fnSplit = filename.split("_");
		int N = Integer.valueOf(fnSplit[1]);
		double[][] xArray = new double[N][12];
		double[] yArray = new double[N];
		int max = -1, runs = -1, iterations = -1;
		double p_broadcast = -1, p_update = -1;
		
		try {
			//Obtain location metrics
			BufferedReader reader = new BufferedReader(new FileReader(filename + "_LMinput.txt"));
			max = Integer.valueOf(reader.readLine());
			while(reader.ready()) {
				String[] split = reader.readLine().split(" ");
				for(int i = 0 ; i < 12 ; i++) {
					xArray[Integer.valueOf(split[0])][i] = Float.valueOf(split[i + 2]);
				}
			}
			reader.close();
			
			//Obtain influence
			reader = new BufferedReader(new FileReader(filename + "_influence.txt"));
			runs = Integer.valueOf(reader.readLine());
			iterations = Integer.valueOf(reader.readLine());
			p_broadcast = Double.valueOf(reader.readLine());
			p_update = Double.valueOf(reader.readLine());
			while(reader.ready()) {
				String[] split = reader.readLine().split(" ");
				for(int i = 0 ; i < 10 ; i++) {
					yArray[Integer.valueOf(split[0])] = Double.valueOf(split[1]);	//Fill in y-array
				}
			}
			reader.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		//Perform linear regression K times with randomly chosen set of size S
		OLSMultipleLinearRegression ols = new OLSMultipleLinearRegression();
		ArrayList<Integer> bucket = new ArrayList<Integer>();
		for(int i = 0 ; i < N ; i++) bucket.add(i);	//Bucket = [0..n]
		
		double[][] parameters = new double[K][12];
		double[] deviations = new double[K];
		for(int i = 0 ; i < K ; i++) {
			double[][] partialXArray;
			double[] partialYArray;
			//This do-loop makes sure the sample matrix is non-singular.
			//This is a requirement for the linear regression performed by Apache
			//and is only a property of the matrix itself, not of the data
			int timesTried = 0;
			do {
				timesTried++;
				Collections.shuffle(bucket);
				List<Integer> sample = bucket.subList(0, S);	//Taking the first S elements of a random permutation of the bucket
				partialXArray = new double[S][12];
				partialYArray = new double[S];
				for(int j = 0 ; j < S ; j++) {
					partialXArray[j] = xArray[sample.get(j)];
					partialYArray[j] = yArray[sample.get(j)];
				}
				//If we've tried unsuccessfully to get a non-singular matrix
				//a small value is added to a random matrix entry. This most likely makes the matrix non-singular
				//but can affect the results drastically, so this is a last resort.
				if(timesTried > 10) {
					partialXArray[(int)(Math.random()*S)][(int)(Math.random()*12)] += 0.001;
				}
			} while(!new QRDecomposition(new Array2DRowRealMatrix(partialXArray)).getSolver().isNonSingular());
			
			ols.newSampleData(partialYArray, partialXArray);
			parameters[i] = ols.estimateRegressionParameters();
			
			System.out.print((i+1) + ": " + parameters[i][0] + " + ");
			for(int j = 1 ; j < 13 ; j++) {
				System.out.print(parameters[i][j] + "*X"+j);
				if(j < 13) System.out.print(" + ");
			}
			System.out.println();
			
			//Test it on all the nodes and compare to their influence. Calculate mean deviation from the real value.
			double deviation = 0;
			for(int j = 0 ; j < N ; j++) {
				double prediction = parameters[i][0];
				for(int lm = 1 ; lm < 13 ; lm++) {
					prediction += xArray[j][lm-1]*parameters[i][lm];
				}
				deviation += Math.abs(yArray[j] - prediction);	//|Y - Y'|
			}
			deviation /= N;		//Average the deviation
			System.out.println("Mean deviation (" + i + "): " + deviation + "\n");
			deviations[i] = deviation;
		}
		
		//Print this all to a file
		try {
			FileWriter writer = new FileWriter("Graph_"+N+"_LRoutput.txt");
			writer.write("N = " + N + "\n");
			writer.write("MAX = " + max + "\n");
			writer.write("Runs = " + runs + "\n");
			writer.write("Iterations = " + iterations + "\n");
			writer.write("P_broadcast = " + p_broadcast + "\n");
			writer.write("P_update = " + p_update + "\n\n");
			writer.write("S = " + S + "\n");
			writer.write("K = " + K + "\n\n");
			
			int correctedK = 0;
			double sum = 0, correctedSum = 0;
			for(int i = 0 ; i < K ; i++) {
				writer.write((i+1) + ": " + parameters[i][0] + " + ");
				writer.write(parameters[i][1] + "*Degree + ");
				writer.write(parameters[i][2] + "*LCC + ");
				writer.write(parameters[i][3] + "*LEE + ");
				writer.write(parameters[i][4] + "*HEE + ");
				writer.write(parameters[i][5] + "*AEE + ");
				writer.write(parameters[i][6] + "*LEO + ");
				writer.write(parameters[i][7] + "*HEO + ");
				writer.write(parameters[i][8] + "*AEO + ");
				writer.write(parameters[i][9] + "*ASPL + ");
				writer.write(parameters[i][10] + "*AND + ");
				writer.write(parameters[i][11] + "*CC + ");
				writer.write(parameters[i][12] + "*BC\n");
				writer.write("Mean deviation: " + deviations[i] + "\n\n");
				if(deviations[i] < 1) {
					correctedSum += deviations[i];
					correctedK++;
				}
				sum += deviations[i];
			}
			writer.write("Average deviation over all samples: " + (sum / K) + "\n");
			writer.write("- without out of bounds deviations: " + (correctedSum / correctedK));
			writer.close();
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}
}
