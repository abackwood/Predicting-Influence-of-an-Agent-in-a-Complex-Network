import java.io.*;
import java.util.*;

public class Graph {
	HashMap<Vertex, EdgeCollection> edges;
	HashMap<Vertex, HashMap<Vertex, Vertex[]>> paths;
	
	Graph(Set<Vertex> vertices) {
		edges = new HashMap<Vertex, EdgeCollection>();
		for(Vertex v : vertices) {
			edges.put(v, new EdgeCollection());
		}
	}
	
	ArrayList<Vertex> neighbours(Vertex v) { return edges.get(v).neighbours; }
	
	//From an arbitrary vertex, we do a breadth-first search to see if all vertices are connected
	boolean connected() {
		Vertex start = edges.keySet().toArray(new Vertex[0])[0];	//Arbitrary first vertex in the graph
		ArrayList<Vertex> reachable = new ArrayList<Vertex>(), border = new ArrayList<Vertex>();
		reachable.add(start);
		border.add(start);
		for(Vertex v : reachable) {
			//System.out.print(v.id+" ");
		}
		//System.out.println();
		while(!border.isEmpty()) {
			ArrayList<Vertex> newborder = new ArrayList<Vertex>();
			for(Vertex v : border) {
				for(Vertex nv : edges.get(v).neighbours) {
					if(!reachable.contains(nv) && !newborder.contains(nv)) {
						newborder.add(nv);
					}
				}
			}
			reachable.addAll(newborder);
			for(Vertex v : reachable) {
				//System.out.print(v.id+" ");
			}
			//System.out.println();
			border = newborder;
		}
		return edges.size() == reachable.size();
	}
	
	void findShortestPaths() {
		//Set up datastructure and fill in with null-paths
		paths = new HashMap<Vertex, HashMap<Vertex,Vertex[]>>();
		for(Vertex v : edges.keySet()) {
			paths.put(v, new HashMap<Vertex, Vertex[]>());
			for(Vertex v1 : edges.keySet()) {
				paths.get(v).put(v1, null);
			}
		}
		
		//For all vertices, do BFS to find all shortest paths
		//Since some paths may have an equally good alternative, resulting BC is somewhat arbitrary. ASPL stays the same.
		for(Vertex v : paths.keySet()) {
			ArrayList<LinkedList<Vertex>> border = new ArrayList<LinkedList<Vertex>>();
			ArrayList<Vertex> taboo = new ArrayList<Vertex>();
			taboo.add(v);
			
			LinkedList<Vertex> start = new LinkedList<Vertex>();
			start.addLast(v);
			border.add(start);
			
			while(!border.isEmpty()) {
				ArrayList<LinkedList<Vertex>> newborder = new ArrayList<LinkedList<Vertex>>();
				for(LinkedList<Vertex> path : border) {
					paths.get(v).put(path.getLast(), path.toArray(new Vertex[0]));	//This is the shortest path to the last node
					//System.out.println("Path " + v.id + " --> " + path.getLast().id + " found");
					
					//Add all paths that are one step further than this border vertex
					for(Vertex v1 : neighbours(path.getLast())) {
						if(!taboo.contains(v1)) {
							LinkedList<Vertex> newpath = new LinkedList<Vertex>(path);
							newpath.addLast(v1);
							newborder.add(newpath);
							taboo.add(v1);
						}
					}
					border = newborder;
				}
			}
		}
	}
	
	float degree(Vertex v) {
		return neighbours(v).size();
	}
	
	float lcc(Vertex v) {
		float total_possible = degree(v) * (degree(v) - 1);
		float total = 0;
		for(Vertex n : neighbours(v)) {
			for(Vertex nn : neighbours(n)) {
				if(neighbours(v).contains(nn)) total++;
			}
		}
		return (total_possible == 0) ? 0 : total / total_possible;
	}
	
	float lee(Vertex v) {
		float lowest = Float.MAX_VALUE;
		for(Vertex n : neighbours(v)) {
			float ee = 0;
			for(Vertex nn : neighbours(n)) {
				if(neighbours(v).contains(nn)) ee++;
			}
			if(ee < lowest) lowest = ee;
		}
		return lowest;
	}
	
	float aee(Vertex v) {
		float sum = 0;
		for(Vertex n : neighbours(v)) {
			float ee = 0;
			for(Vertex nn : neighbours(n)) {
				if(neighbours(v).contains(nn)) ee++;
			}
			sum += ee;
		}
		return sum / degree(v);
	}
	
	float hee(Vertex v) {
		float highest = 0;
		for(Vertex n : neighbours(v)) {
			float ee = 0;
			for(Vertex nn : neighbours(n)) {
				if(neighbours(v).contains(nn)) ee++;
			}
			if(ee > highest) highest = ee;
		}
		return highest;
	}
	
	float leo(Vertex v) {
		float lowest = Float.MAX_VALUE;
		for(Vertex n : neighbours(v)) {
			float ee = 0;
			for(Vertex nn : neighbours(n)) {
				if(neighbours(v).contains(nn)) ee++;
			}
			float eo = (2 * ee) / (degree(v) + degree(n));
			if(eo < lowest) lowest = eo;
		}
		return lowest;
	}
	
	float aeo(Vertex v) {
		float sum = 0;
		for(Vertex n : neighbours(v)) {
			float ee = 0;
			for(Vertex nn : neighbours(n)) {
				if(neighbours(v).contains(nn)) ee++;
			}
			float eo = (2 * ee) / (degree(v) + degree(n));
			sum += eo;
		}
		return sum / degree(v);
	}
	
	float heo(Vertex v) {
		float highest = 0;
		for(Vertex n : neighbours(v)) {
			float ee = 0;
			for(Vertex nn : neighbours(n)) {
				if(neighbours(v).contains(nn)) ee++;
			}
			float eo = (2 * ee) / (degree(v) + degree(n));
			if(eo > highest) highest = eo;
		}
		return highest;
	}
	
	float aspl(Vertex v) {	//Average Shortest Path Length
		float sum = 0;
		for(Vertex[] vToX : paths.get(v).values()) {
			sum += vToX.length;
		}
		return sum / paths.get(v).size();
	}
	
	float and(Vertex v) {	//Average Neighbor Degree
		float sum = 0;
		for(Vertex n : edges.get(v).neighbours) {
			sum += degree(n);
		}
		return sum / degree(v);
	}
	
	float cc(Vertex v) {	//Closeness Centrality: the reciprocal of ASPL
		return 1 / aspl(v);
	}
	
	float bc(Vertex v) {	//Betweenness Centrality: fraction of all NxN shortest paths in the network that contain the vertex
		float total = 0;
		for(HashMap<Vertex, Vertex[]> map : paths.values()) {
			for(Vertex[] path : map.values()) {
				for(Vertex step : path) {
					if(step.equals(v)) {
						total++;
						break;
					}
				}
			}
		}
		return total / (edges.size() * edges.size());
	}
	
	void printToFile(File f, int max) {
		for(Vertex v : edges.keySet()) {
			//System.out.print(v.id + " : ");
			for(Vertex vn : edges.get(v).neighbours) {
				//System.out.print(vn.id + " ");
			}
			//System.out.println();
		}
		
		try {
			FileWriter fw = new FileWriter(f + "_NLinput.txt");
			fw.write("create-turtles "+RandomGraphGenerator.N+"\n");
			for(Vertex v : edges.keySet()) {
				fw.write("ask turtle "+v.id+" [ create-links-with (turtle-set ");
				for(Vertex vn : edges.get(v).neighbours) {
					fw.write("turtle "+vn.id+" ");
				}
				fw.write(") ]\n");
			}
			fw.close();
			
			fw = new FileWriter(f + "_LMinput.txt");
			fw.write(max + "\n");
			for(Vertex v : edges.keySet()) {
				fw.write(v.id + " :: " + printAllMetrics(v) + "\n");
			}
			fw.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	private String printAllMetrics(Vertex v) {
		return 	degree(v) + " "
				+ lcc(v) + " "
				+ lee(v) + " "
				+ hee(v) + " "
				+ aee(v) + " "
				+ leo(v) + " "
				+ heo(v) + " "
				+ aeo(v) + " "
				+ aspl(v) + " "
				+ and(v) + " "
				+ cc(v) + " "
				+ bc(v) + " ";
	}
}

class Vertex {
	static int nextID;
	int id;
	
	Vertex() {
		id = nextID;
		nextID++;
	}
	
	public boolean equals(Object o) {
		Vertex v = (Vertex)o;
		return id == v.id;
	}
}

class EdgeCollection {
	ArrayList<Vertex> neighbours;
	EdgeCollection() {
		neighbours = new ArrayList<Vertex>();
	}
}