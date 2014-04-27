import java.io.*;
import java.util.*;

public class RandomGraphGenerator {
	//PARAMETERS
	static final int N = 200;			//Number of nodes
	static final int MAX_DEGREE = 15;	
	
	static int sum;
	
	public static void main(String[] args) {
		Graph g = null;
		int numOfAttempts = 0;
		do {
			numOfAttempts++;
			System.out.println("Attempt "+numOfAttempts + "...");
			g = generate();
		} while(sum > 0 || !g.connected());
		if(g != null) {
			g.findShortestPaths();
			/*for(Vertex source : g.paths.keySet()) {
				for(Vertex dest : g.paths.get(source).keySet()) {
					System.out.print(source.id + " --> " + dest.id + " :: ");
					if(g.paths.get(source) == null) System.out.print("No source!");
					for(Vertex step : g.paths.get(source).get(dest)) {
						//System.out.print(step.id + " ");
					}
					System.out.println();
				}
			}*/
			g.printToFile(new File("Graph_" + N), MAX_DEGREE);
		}
	}
	
	static Graph generate() {
		HashMap<Vertex, Integer> dlist = new HashMap<Vertex, Integer>();
		sum = 0;
		Vertex.nextID = 0;
		for(int i = 0 ; i < N ; i++) {
			int di = 1 + (int)(Math.random()*(MAX_DEGREE - 1));		//A random number between 1 and MAX
			dlist.put(new Vertex(), di);
			sum += di;
		}
		Graph g = new Graph(dlist.keySet());
		
		while(true) {
			//Pick the two vertices i and j for a new edge
			//j is picked from the dlist reduced by vi and vi's neighbours
			Vertex vi, vj;
			HashMap<Vertex, Integer> reduced_dlist;
			boolean vi_found;
			do {	//Keep searching for a good match.
				vi_found = true;
				vi = pickRandomVertex(dlist);
				if(vi == null) return g;	//No more edges can be added. We're done.
				reduced_dlist = new HashMap<Vertex, Integer>(dlist);
				reduced_dlist.remove(vi);
				for(Vertex nv : g.edges.get(vi).neighbours) {
					reduced_dlist.remove(nv);
				}
				vj = pickRandomVertex(reduced_dlist);	//Pick vj from a filtered dlist without vi and its neighbours
				if(vj == null) {	//This will start happening more towards the end
					dlist.remove(vi);	//No more edges are possible from this vertex, so it should be disqualified from the random pick
					vi_found = false;
				}
			} while(!vi_found);
			g.neighbours(vi).add(vj);		//Add the edge to both vertices
			g.neighbours(vj).add(vi);
			dlist.put(vi, dlist.get(vi) - 1);		//Lower the degree of both by one
			dlist.put(vj, dlist.get(vj) - 1);
			sum -= 2;	//Update the total sum of d
		}
	}
	
	//Pick a random vertex that still has degree left over by way of weighted lottery
	static Vertex pickRandomVertex(HashMap<Vertex, Integer> dlist) {
		ArrayList<Vertex> weightedList = new ArrayList<Vertex>();
		for(Vertex v : dlist.keySet()) {	//For every vertex in dlist
			for(int x = 0 ; x < dlist.get(v) ; x++) {
				weightedList.add(v);		//... add v to the weighted list d(v) times
			}
		}
		if(weightedList.isEmpty()) return null;
		return weightedList.get((int)(Math.random()*weightedList.size()));	//Draw a random element from the weighted list
	}
}
