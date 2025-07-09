class AgentManager {
  ArrayList<Agent> agents  = new ArrayList<Agent>();

  void moveAgents() {
    for (Agent agent : agents) {
      agent.applyForce(gravity);
      agent.applyForce(wind);
      agent.update();      
      agent.display();
      for (ColliderRect r : rects) {
        r.collideWith(agent.pos, agent.vel);
      }
      //agent.checkEdges();
    }
  }

  void removeAgents() {
    ArrayList<Agent> tempAgents = new ArrayList<Agent>();
    for (Agent tempAgent : agents) {
      if ((tempAgent.pos.x > 0) && (tempAgent.pos.x < width) && (tempAgent.pos.y < height)) {
        tempAgents.add(tempAgent);
      }
    }
    agents = tempAgents;
  }
}
