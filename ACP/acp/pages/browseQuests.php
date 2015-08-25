<div class="row">
                <div class="col-lg-8">
                    <h1 class="page-header">Quests</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->
            <div class="row">
                <div class="col-lg-8">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            Save 2 babies from a burning building [x]
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-striped table-bordered table-hover" id="dataTables-example">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Name</th>
                                            <th>Required level</th>
                                            <th>Rewards</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        
                                        <?php
		$stmt = $db->prepare('SELECT * FROM quests ORDER BY id ASC');
		$stmt->execute();

		$result = $stmt->fetchAll();
            if(empty($result)){
                echo "<tr><td>#</td><td>No quests?</td><td>#</td><td>#</td></tr>";
            }
			foreach($result as $row) {
				echo "<tr>";
                echo "<td>".$row["id"]."</td>";
                echo "<td><a href='Main.php?div=editQuest&ien=".$row["id"]."'>".$row["name"]."</a></td>";
                echo "<td>".$row["reqLevel"]."</td>";
                echo "<td>".$row["rewards"]."</td>";
                echo "</tr>";
            }
                    ?>
					
                                    </tbody>
                                </table>
                            </div>
                            <!-- /.table-responsive -->
                        </div>
                        <!-- /.panel-body -->
                    </div>
                    <!-- /.panel -->
                </div>
                <!-- /.col-lg-12 -->
            </div>