<div class="row">
                <div class="col-lg-12">
                    <h1 class="page-header">Items</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->
            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <a href="Main.php?div=addItems">Add item</a>
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-striped table-bordered table-hover" id="dataTables-example">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Name</th>
                                            <th>Description</th>                                                             </tr>
                                    </thead>
                                    <tbody>
                                        
                                        <?php
		$stmt = $db->prepare('SELECT * FROM items ORDER BY id ASC');
		$stmt->execute();

		$result = $stmt->fetchAll();
			foreach($result as $row) {
				echo "<tr>";
                echo "<td>".$row["id"]."</td>";
                echo "<td><a href='Main.php?div=editItem&ien={$row['id']}'>".$row["name"]."</a></td>";
                echo "<td>".$row["desc"]."</td>";
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