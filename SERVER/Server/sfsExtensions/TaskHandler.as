function handleTasks(taskObj){
	var task = taskObj.id;
	var cmd = task.cmd;
	switch(cmd){
		case 'respawnEnemy':
			respawnEnemy(task);
		break;
		case 'attackAI':
			if(task.room != null){
				attackAI(task, taskObj);
			}
		break;
		case 'auraTick':
			auraTick(task, taskObj);
		break;
		case 'restLoop':
			restLoop();
		break;
		default:
			trace("Undefined task: " + cmd)
		break;
	}
}