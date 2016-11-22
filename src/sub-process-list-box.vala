using Gee;
using Posix;

namespace Usage
{
     public class SubProcessListBox : Gtk.Box
     {
         HashTable<pid_t?, SubProcessSubRow> process_sub_rows_table;

         public SubProcessListBox()
         {
             orientation = Gtk.Orientation.VERTICAL;
             process_sub_rows_table = new HashTable<pid_t?, SubProcessSubRow>(int_hash, int_equal);
         }

         public string get_first_name()
         {
             return process_sub_rows_table.get_values().nth_data(0).get_name();
         }

         public pid_t get_first_pid()
         {
             return process_sub_rows_table.get_values().nth_data(0).get_pid();
         }

         public int get_first_value()
         {
             return process_sub_rows_table.get_values().nth_data(0).get_value();
         }

         public uint get_sub_rows_count()
         {
             return process_sub_rows_table.length;
         }

         public bool is_in_table(pid_t pid)
         {
             return ((int) pid in process_sub_rows_table);
         }

         public void pre_update()
         {
             foreach(unowned SubProcessSubRow sub_row in process_sub_rows_table.get_values())
                 sub_row.set_alive(false);
         }

         public void post_update()
         {
             this.forall ((element) => this.remove (element)); //clear box

             var sub_rows_sorted = new Gee.ArrayList<unowned SubProcessSubRow>();
             foreach(unowned SubProcessSubRow sub_row in process_sub_rows_table.get_values())
             {
                 sub_row.update();
                 if(sub_row.get_alive() == false)
                     process_sub_rows_table.remove((int) sub_row.get_pid());
                 else
                     sub_rows_sorted.add(sub_row);
             }

             sort(sub_rows_sorted);

             foreach(unowned SubProcessSubRow sub_row in sub_rows_sorted)
                 this.add(sub_row);
         }

         public void add_sub_row(pid_t pid, int value, string name)
         {
             SubProcessSubRow sub_row = new SubProcessSubRow((int) pid, value, name);
             process_sub_rows_table.insert ((int) pid, (owned) sub_row);
         }

         public void update_sub_row(pid_t pid, int value)
         {
             unowned SubProcessSubRow sub_row = process_sub_rows_table[(int) pid];
             sub_row.set_value(value);
         }

         public void remove_all()
         {
             this.forall ((element) => this.remove (element)); //clear box
             process_sub_rows_table.remove_all();
         }

         public Gee.ArrayList<int> get_values()
         {
             var list = new Gee.ArrayList<int>();
             foreach(unowned SubProcessSubRow sub_row in process_sub_rows_table.get_values())
                 list.add(sub_row.get_value());

             return list;
         }

         public int get_values_sum()
         {
             int sum = 0;
             foreach(unowned SubProcessSubRow sub_row in process_sub_rows_table.get_values())
                 sum += sub_row.get_value();

             return sum;
         }

         private void sort(Gee.ArrayList<unowned SubProcessSubRow> sub_rows)
         {
             sub_rows.sort((a, b) => {
                 return a.get_value() - b.get_value();
             });
         }
     }
}
