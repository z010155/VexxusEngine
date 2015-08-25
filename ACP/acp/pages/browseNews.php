<div class="row">
                <div class="col-lg-12">
                    <h1 class="page-header">News</h1>
                </div>
                <!-- /.col-lg-12 -->
            </div>
            <!-- /.row -->
            <div class="row">
                <div class="col-lg-12">
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <a href="Main.php?div=addNews">Add news</a>
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <div class="table-responsive">
                                <table class="table table-striped table-bordered table-hover" id="dataTables-example">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Subject</th>
                                            <th>News text</th>
                                            <th>Author</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        
        <?php
		$stmt = $db->prepare('SELECT * FROM news ORDER BY id DESC');
		$stmt->execute();

		$result = $stmt->fetchAll();
            if(empty($result)){
                echo "<tr><td>#</td><td>No news?</td><td>#</td><td>#</td></tr>";
            }
			foreach($result as $row) {
				echo "<tr>";
                echo "<td>".$row["id"]."</td>";
                echo "<td><a href='Main.php?div=editNews&ien={$row['id']}'>".$row["subject"]."</a></td>";
                echo "<td>".$row["newstext"]."</td>";
                
                    $stmt2 = $db->prepare('SELECT * FROM characters WHERE id=:id');
                    $stmt2->execute(array(':id'=>$row["userid"]));

                    $result2 = $stmt2->fetchAll();
                    foreach($result2 as $row2) {
                        echo "<td>".$row2["username"]."</td>";
                    }
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