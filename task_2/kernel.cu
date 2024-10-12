#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <iostream>
#include <list>
#include <vector>

using std::cout; using std::vector;

vector<vector<int>> components; //Global declaration of components vector

//Graph representation using adjacency matrix
class Graph {
    public:
    int Vert;
    //Creating our adjacency matrix with name Adj
    vector<vector<bool>>Adj;

    //Init 
    Graph(int Vert){
        this->Vert=Vert;
        //Actually making the adjacency matrix
        Adj.resize(Vert,vector<bool>(Vert,false));
        }

    //Method(?) to add an edge to the graph
    void AddEdge(int x, int y){
        Adj[x][y]=true;
        Adj[y][x]=true; //Assuming undirected graph.
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
};