#include <iostream>
#include <list>
#include <vector>

using std::cout; using std::vector;

vector<vector<int>> components; //Global declaration of components vector

//Graph representation using adjacency list
class Graph {
    public:
    int Vert;
    //Creating our adjacency list with name Adj
    vector<vector<int>>Adj;

    //Init 
    Graph(int Vert){
        this->Vert=Vert;
        //creating Vert number of empty vectors inside our Adj to represent each vertex's neighbors
        for(int i=0; i<Vert; i++){
            vector<int> v;
            Adj.push_back(v);
        }
        }

    //Method(?) to add an edge to the graph
    void AddEdge(int x, int y){
        Adj[x].push_back(y);
        Adj[y].push_back(x); //Assuming undirected graph.
    }

    //Method to number of connected components
    int findComponents(){
    bool visited[Vert];
    int count;
    for(int i=0; i<Vert;i++){
        visited[i] = false;
    }
    for(int i=0; i<Vert;i++){
        if (!visited[i]){
            vector<int> subcomponents = {};
            dfs(i, visited, subcomponents);
            components.push_back(subcomponents);
            count++;
        }
    }
    return count;
    }

    //Defining a dfs function
    void dfs(int at, bool* visited, vector<int> &subcomponents){
    visited[at] = true;
    subcomponents.push_back(at);
    for(int nbridx = 0; nbridx<Adj[at].size(); nbridx++){
        if(!visited[Adj[at][nbridx]]){
            dfs(Adj[at][nbridx], visited, subcomponents);
        }
    }
    return;
    }

    //Method to print the graph
    void PrintGraph(){
        for(int i=0; i<Vert;i++){
            cout<<i<<"\t";
            for(int j=0; j<Adj[i].size();j++){
                cout<<Adj[i][j]<<",";
            }
            cout<<std::endl;
        }
    }

    void PrintComponents(){
        for(int i=0; i<components.size();i++){
            cout << "component " << i << "\t" ;
            for(int j=0; j<components[i].size();j++){
                cout<<components[i][j]<<",";
            }
            cout<<std::endl;
        }
    }
    };

//Main function
int main(){
    Graph g(16);
    g.AddEdge(0,10);
    g.AddEdge(0,9);
    g.AddEdge(8,9);
    g.AddEdge(4,9);
    g.AddEdge(8,4);
    g.AddEdge(4,6);
    g.AddEdge(11,15);
    g.AddEdge(5,11);
    g.AddEdge(1,5);
    g.AddEdge(1,15);
    g.AddEdge(2,12);
    g.AddEdge(2,7);
    g.AddEdge(7,12);
    g.AddEdge(13,7);
    g.AddEdge(13,12);
    g.PrintGraph();
    cout << "Number of Vertices = " << g.Vert << std::endl;
    cout << "Number of components = " << g.findComponents() << std::endl;
    g.PrintComponents();
    return 0;
}