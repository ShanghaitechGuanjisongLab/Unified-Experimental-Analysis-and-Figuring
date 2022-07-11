本工具箱立志收集管吉松实验室所有数据分析作图代码，并使用统一的UniExp格式。

依赖[埃博拉酱的MATLAB扩展](https://ww2.mathworks.cn/matlabcentral/fileexchange/96344-matlab-extension)、[埃博拉酱的并行计算工具箱](https://ww2.mathworks.cn/matlabcentral/fileexchange/99194-parallel-computing)、[Image5D](https://ww2.mathworks.cn/matlabcentral/fileexchange/114435-image5d-oir-tiff)

# UniExp文件格式
UniExp是一种模仿SQL数据库架构的MATLAB表格文件格式，由6张符合BC范式的数据表组成，每张表包含主键和必选列，可以额外添加可选列：
- DateTimes，主键DateTime，实验进行的时间日期，本表其它列可选，但应当是与该次实验特定的信息，例如鼠、拍摄采样率、元数据等
- Blocks，主键BlockUID，模块的唯一标识符；码(DateTime,BlockIndex)，因为“一次特定实验的第N个模块”应当可以唯一确定一个模块。主键和码应当一一对应且不能重复。其它可选列应当是特定于该模块的信息，如模块设计名称、标通道值、事件日志等
- Trials，主键TrialUID，回合的唯一标识符；码(BlockUID,TrialIndex)，因为“一个特定模块的第N回合”应当可以唯一确定一个回合。其它可选列应当是特定于该回合的信息，如刺激类型、标通道值、采样时点、动物行为等。
- Cells，主键CellUID，细胞的唯一标识符；码(Mouse,ZLayer,CellType,CellIndex)，因为“一只鼠某层某种类型的第N个细胞”应当可以唯一确定一个细胞。其它可选列应当是特定于该细胞的信息，如像素位置等。
- BlockSignals，主键(CellUID,BlockUID)，用模块和细胞的组合唯一标识该细胞在该模块的活动，可选列如BlockSignal等
- TrialSignals，主键(CellUID,TrialUID)，用回合和细胞的组合唯一标识该细胞在该回合的活动，可选列如TrialSignal等

上述数据表以 MATLAB table 格式存储在.mat文件中。建议扩展名使用.UniExp.mat表示该文件为UniExp数据表。

这些表格可以使用【埃博拉酱的MATLAB扩展】中的MATLAB.DataTypes.Select方法进行基本的连接查询。有些 UniExp API 会要求以查询结果作为输入。
# UniExp API
为了获取、处理和使用UniExp格式文件，本工具箱包含一系列数据处理函数，都在UniExp包内，使用前需导入：
```MATLAB
import UniExp.*
```
每个函数代码文件内都有详尽文档，可用`doc UniExp.函数名`查询。函数的使用示例可在快速入门文档GettingStarted.mlx中查看。下方仅列出这些函数的简介。
## 从其它数据文件格式取得UniExp
```MATLAB
%批量配准 Olympus OIR 文件并转码为OME-TIFF格式，自动排除电流检测（Current Detector, CD）通道
function BatchOirRegisterTiff(OirPaths,ReferencePath,OutputDirectory,options)
```
## UniExp内部处理
```MATLAB
%从事件记录取得命中率
function HitRates = EventLog2HitRate(EventLogs,Tags)
%生成带有平均值和标准误的学习曲线数据（不作图）
function [Design,Mean,Sem]=LearningCurve(DataTable)
%合并多个UniExp数据库
function Merged = MergeCommits(Commits,ChangeUID)
```